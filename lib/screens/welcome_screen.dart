import 'package:cropsync/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../widgets/buttons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
        PrimaryButton(text: 'Login', onPressed: () {}),
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
