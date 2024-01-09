import 'package:cropsync/screens/welcome_screen.dart';
import 'package:cropsync/services/user_model.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import 'package:watch_it/watch_it.dart';

class ProfileScreen extends WatchingWidget {
  const ProfileScreen({super.key});

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

    return Center(
      child: SafeArea(
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
            ],
          ),
        ),
      ),
    );
  }
}
