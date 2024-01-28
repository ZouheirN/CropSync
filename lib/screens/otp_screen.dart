import 'package:cropsync/json/user.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/services/user_api.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pinput/pinput.dart';
import 'package:watch_it/watch_it.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String status = '';

  Future<void> checkOTP(pin) async {
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    final isResettingPassword = arg['isResettingPassword'] ?? false;
    final token = arg['token'] ?? '';

    setState(() {
      status = 'Checking OTP...';
    });

    await Future.delayed(const Duration(seconds: 2));

    if (isResettingPassword) {
      if (!mounted) return;
      Navigator.of(context).pushNamed('/change-password', arguments: {
        'forgotPassword': true,
        'token': arg['token'],
      });
    } else {
      final otpResult = await UserApi.verifyEmail(
        pin: pin,
        token: token
      );

      if (otpResult == ReturnTypes.fail) {
        setState(() {
          status = 'Wrong OTP. Try again.';
        });
        return;
      } else if (otpResult == ReturnTypes.invalidToken) {
        if (!context.mounted) return;
        invalidTokenResponse(context);
        return;
      }

      final user = User.fromJson(otpResult);
      di<UserModel>().user = user;
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    final isNotVerifiedFromLogin = arg['isNotVerifiedFromLogin'] ?? false;
    final isResettingPassword = arg['isResettingPassword'] ?? false;

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
              if (isNotVerifiedFromLogin)
                const Text(
                  'Your account is not verified yet. Please enter the OTP sent to your email to verify your account',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )
              else if (isResettingPassword)
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
