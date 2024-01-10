import 'dart:ui';

import 'package:cropsync/screens/login_screen.dart';
import 'package:cropsync/screens/register_screen.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: ExactAssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
              ),
            ),
          ),
          Opacity(
            opacity: 0.2,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment(0.8, 1),
                  colors: <Color>[
                    Color(0xffA53B00),
                    Color(0xff9C9C9C),
                    Color(0xff1A552A),
                  ],
                  tileMode: TileMode.mirror,
                ),
              ),
            ),
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
                  // color: Colors.green,
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
        PrimaryButton(
          text: 'Login',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
        ),
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
