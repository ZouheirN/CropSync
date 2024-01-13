import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pinput/pinput.dart';

class OTPScreen extends StatefulWidget {
  final String? token;
  final bool isNotVerifiedFromLogin;
  final bool isResettingPassword;
  final String? email;

  const OTPScreen({
    super.key,
    this.isNotVerifiedFromLogin = false,
    this.token,
    this.isResettingPassword = false,
    this.email,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String status = '';

  Future<void> checkOTP(pin) async {
    setState(() {
      status = 'Checking OTP...';
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      status = 'Wrong OTP. Try again.';
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('One-Time Password'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Gap(100),
              if (widget.isNotVerifiedFromLogin)
                const Text(
                  'Your account is not verified yet. Please enter the OTP sent to your email to verify your account',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )
              else if (widget.isResettingPassword)
                const Text(
                    'In order to reset your password, please enter the OTP sent to your email',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)
              else
                const Text(
                  'Enter the OTP sent to your email',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              const Gap(100),
              Pinput(
                enabled: status != 'Checking OTP...',
                length: 6,
                onCompleted: checkOTP,
                onChanged: (value) {
                  if (value.length < 6) {
                    setState(() {
                      status = '';
                    });
                  }
                },
                focusedPinTheme: PinTheme(
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFF4F5F7),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                defaultPinTheme: PinTheme(
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFF4F5F7),
                    border: Border.all(
                      color: const Color(0xFFDEE3EB),
                    ),
                  ),
                ),
              ),
              const Gap(50),
              Text(
                status,
                style: TextStyle(
                  color: status == 'Wrong OTP. Try again.'
                      ? Colors.red
                      : Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
