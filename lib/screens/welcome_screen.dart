import 'dart:convert';

import 'package:cropsync/json/user.dart';
import 'package:cropsync/screens/main_screen.dart';
import 'package:cropsync/screens/register_screen.dart';
import 'package:cropsync/services/user_model.dart';
import 'package:cropsync/services/user_token.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:watch_it/watch_it.dart';

Future<String> _loadData() async {
  return await rootBundle.loadString('assets/user.json');
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _login(BuildContext context) async {
    // TODO get user info from api
    String jsonString = await _loadData();
    final data = json.decode(jsonString);
    User user = User.fromJson(data);

    di<UserModel>().user = user;
    UserToken.setToken(data['token']);

    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    _buildText(),
                    const Gap(380),
                    _buildButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Text
  Widget _buildText() {
    return Column(
      children: [
        const Gap(40),
        RichText(
          text: const TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: 'Welcome To ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 40,
                ),
              ),
              TextSpan(
                text: ' Crop',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 65, 54),
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
              TextSpan(
                text: 'Sync',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Buttons
  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(text: 'Login', onPressed: () => _login(context)),
        const Gap(20),
        Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 5, right: 15),
                child: const Divider(
                  color: Colors.white,
                  height: 10,
                ),
              ),
            ),
            const Text(
              'or',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 15, right: 5),
                child: const Divider(
                  color: Colors.white,
                  height: 10,
                ),
              ),
            ),
          ],
        ),
        const Gap(20),
        PrimaryButton(
          text: 'Register',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const RegisterScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
