import 'dart:ui';

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
              filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
              child: Opacity(
                opacity: 0.55,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(164, 59, 0, 0.5400000214576721),
                        Color.fromRGBO(161, 99, 64, 0.500598132610321),
                        Color.fromRGBO(156, 156, 156, 0.4449999928474426),
                        Color.fromRGBO(25, 85, 41, 0.699999988079071)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 40,
                right: 40,
                top: 20,
                bottom: 80,
              ),
              child: Column(
                children: [
                  buildTitle(),
                  // const Gap(270),
                  Expanded(flex: 5, child: Container()),
                  buildText(),
                  const Spacer(),
                  buildButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Title
  Widget buildTitle() {
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
                  color: Color.fromARGB(255, 77, 55, 39),
                  // color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
              TextSpan(
                text: 'Sync',
                style: TextStyle(
                  color: Color.fromARGB(255, 22, 149, 72),
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Text
  Widget buildText() {
    return const Column(
      children: [
        Gap(20),
        Text(
          'Monitor your crops and get real-time updates!',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  // Buttons
  Widget buildButtons(BuildContext context) {
    return Column(
      children: [
        CommonButton(
          text: 'Login',
          backgroundColor: Theme.of(context).primaryColor,
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).pushNamed('/login');
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
        CommonButton(
          text: 'Register',
          backgroundColor: Theme.of(context).primaryColor,
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).pushNamed('/register');
          },
        ),
      ],
    );
  }
}
