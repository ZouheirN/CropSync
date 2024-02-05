import 'dart:async';

import 'package:cropsync/main.dart';
import 'package:cropsync/services/user_api.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/textfields.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class Dialogs {
  static void showErrorDialog(String title, String text, BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      animType: QuickAlertAnimType.slideInUp,
      title: title,
      text: text,
      backgroundColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.white
          : const Color(0xFF1B2522),
      textColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.black
          : Colors.white,
      titleColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.black
          : Colors.white,
      confirmBtnColor: Colors.green,
    );
  }

  static void showLoadingDialog(String text, BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      animType: QuickAlertAnimType.slideInUp,
      text: text,
      barrierDismissible: false,
      backgroundColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.white
          : const Color(0xFF1B2522),
      textColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.black
          : Colors.white,
      titleColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.black
          : Colors.white,
      disableBackBtn: true,
    );
  }

  static void showSuccessDialog(
      String title, String text, BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      animType: QuickAlertAnimType.slideInUp,
      title: title,
      text: text,
      backgroundColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.white
          : const Color(0xFF1B2522),
      textColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.black
          : Colors.white,
      titleColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.black
          : Colors.white,
      confirmBtnColor: Colors.green,
    );
  }

  static Future<bool> showConfirmationDialog(
      String title, String text, BuildContext context) async {
    Completer<bool> completer = Completer<bool>();

    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: title,
      text: text,
      confirmBtnText: 'Yes',
      showCancelBtn: true,
      cancelBtnText: 'No',
      confirmBtnColor: Colors.green,
      animType: QuickAlertAnimType.slideInUp,
      backgroundColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.white
          : const Color(0xFF1B2522),
      textColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.black
          : Colors.white,
      titleColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.black
          : Colors.white,
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        completer.complete(true);
      },
      onCancelBtnTap: () {
        Navigator.of(context).pop();
        completer.complete(false);
      },
    );

    return completer.future;
  }

  static Future<void> showInformationDialog(
      String title, String text, BuildContext context) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      animType: QuickAlertAnimType.slideInUp,
      title: title,
      text: text,
      backgroundColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.white
          : const Color(0xFF1B2522),
      textColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.black
          : Colors.white,
      titleColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.black
          : Colors.white,
      confirmBtnColor: Colors.green,
    );
  }

  static void showForgotPasswordDialog(BuildContext context) {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Forgot Password?", textAlign: TextAlign.center),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter your email to reset it"),
              const SizedBox(height: 10),
              PrimaryTextField(
                hintText: 'Enter your email',
                textController: textController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }

                  if (!EmailValidator.validate(value.trim(), true, true)) {
                    return 'Please enter a valid email';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DialogButton(
                    text: 'Cancel',
                    color: Colors.red,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  DialogButton(
                    text: 'Submit',
                    color: Colors.green,
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        // send otp
                        final response = await UserApi.sendResetPasswordOtp(
                            email: textController.text.trim());

                        if (response == ReturnTypes.fail) {
                          if (!context.mounted) return;
                          showErrorDialog(
                              'Error', 'Failed to send OTP', context);
                          return;
                        } else if (response == ReturnTypes.error) {
                          if (!context.mounted) return;
                          showErrorDialog(
                              'Error', 'An error occurred', context);
                          return;
                        }

                        if (!context.mounted) return;
                        Navigator.of(context)
                            .pushReplacementNamed('/otp', arguments: {
                          'email': textController.text.trim(),
                          'isResettingPassword': true,
                        });
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
