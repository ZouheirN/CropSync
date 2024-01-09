import 'package:cropsync/main.dart';
import 'package:cropsync/screens/welcome_screen.dart';
import 'package:cropsync/services/user_model.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:flutter/material.dart';
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

    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = watchPropertyValue((UserModel m) => m.user);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Name'),
              Text(user.fullName),
              const Gap(100),
              ElevatedButton(
                child: const Text('Change microId'),
                onPressed: () {
                  di<UserModel>().user.microId = ['1234567890'];
                },
              ),
              ElevatedButton(
                child: const Text('remove microId'),
                onPressed: () {
                  di<UserModel>().user.microId = [];
                },
              ),
              PrimaryButton(text: 'Logout', onPressed: () => _logout(context)),
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
                    MyApp.themeNotifier.value == ThemeMode.light ? true : false,
                  );

                  setState(() {
                    MyApp.themeNotifier.value =
                        MyApp.themeNotifier.value == ThemeMode.light
                            ? ThemeMode.dark
                            : ThemeMode.light;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
