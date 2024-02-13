import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/textfields.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:watch_it/watch_it.dart';

class AccountInformationScreen extends WatchingWidget {
  final BuildContext context;

  const AccountInformationScreen({super.key, required this.context});

  changePassword() async {
    Navigator.of(context).pushNamed(
      '/change-password',
      arguments: {'forgotPassword': false},
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = watchPropertyValue((UserModel m) => m.user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: ListView(
          children: [
            const Text(
              'Full Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(10),
            PrimaryTextField(hintText: user.fullName!, enabled: false),
            const Gap(20),
            const Text(
              'Email',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(10),
            PrimaryTextField(hintText: user.email!, enabled: false),
            const Gap(20),
            const Text(
              'Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(10),
            CommonButton(
              text: 'Change Password',
              onPressed: changePassword,
              textColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}