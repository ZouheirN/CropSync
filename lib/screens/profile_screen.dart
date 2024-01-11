import 'package:cropsync/main.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import 'package:watch_it/watch_it.dart';

class ProfileScreen extends WatchingStatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _logout(BuildContext context) {
    di<UserModel>().logout();

    Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = watchPropertyValue((UserModel m) => m.user);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: SingleChildScrollView(
          child: AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  const CircleAvatar(
                    radius: 50,
                    // backgroundImage: NetworkImage(user.profilePictureUrl),
                  ),
                  const Gap(20),
                  Text(user.fullName, style: const TextStyle(fontSize: 24)),
                  const Gap(100),
                  ListTile(
                    leading: Icon(MyApp.themeNotifier.value == ThemeMode.light
                        ? Icons.dark_mode
                        : Icons.light_mode),
                    title: Text(MyApp.themeNotifier.value == ThemeMode.light
                        ? 'Switch to Dark Mode'
                        : 'Switch to Light Mode'),
                    onTap: () async {
                      final userPrefsBox = Hive.box('userPrefs');

                      userPrefsBox.put(
                        'darkModeEnabled',
                        MyApp.themeNotifier.value == ThemeMode.light
                            ? true
                            : false,
                      );

                      setState(() {
                        MyApp.themeNotifier.value =
                            MyApp.themeNotifier.value == ThemeMode.light
                                ? ThemeMode.dark
                                : ThemeMode.light;
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded),
                    title: const Text('Logout'),
                    onTap: () => _logout(context),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
