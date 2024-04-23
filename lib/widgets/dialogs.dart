import 'dart:async';

import 'package:cropsync/main.dart';
import 'package:cropsync/services/resnet_model_helper.dart';
import 'package:cropsync/services/user_api.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/textfields.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
              const Gap(10),
              PrimaryTextField(
                prefixIcon: const Icon(Icons.email_rounded),
                hintText: 'Email',
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
              const Gap(10),
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
                              'Error', 'An error occurred, try again', context);
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

  static Future<int> showWaterDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();

    Completer<int> completer = Completer<int>();

    int selectedSeconds = 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Water Crop', textAlign: TextAlign.center),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select the amount of water to dispense"),
              const SizedBox(height: 10),
              SizedBox(
                height: 150, // Adjust height as needed
                child: ListWheelScrollView(
                  itemExtent: 42,
                  useMagnifier: true,
                  magnification: 1.5,
                  physics: const BouncingScrollPhysics(),
                  children: List.generate(
                    16, // Generate numbers from 0 to 60
                    (index) => Center(
                        child: Text('${(index + 1) * 30}ml (${index + 1}s)')),
                  ),
                  onSelectedItemChanged: (index) {
                    selectedSeconds = index + 1;
                  },
                ),
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
                      completer.complete(-1);
                    },
                  ),
                  DialogButton(
                    text: 'Water',
                    color: Colors.green,
                    onPressed: () async {
                      completer.complete(selectedSeconds);
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );

    return completer.future;
  }

  static Future<String> showChangePredictionDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();

    Completer<String> completer = Completer<String>();

    int selectedPrediction = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Prediction', textAlign: TextAlign.center),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select the actual prediction"),
              const SizedBox(height: 10),
              SizedBox(
                height: 150, // Adjust height as needed
                child: ListWheelScrollView(
                  itemExtent: 42,
                  useMagnifier: true,
                  magnification: 1.5,
                  physics: const BouncingScrollPhysics(),
                  children: ResNetModelHelper().classLabels.map(
                    (e) {
                      return Center(child: Text(e));
                    },
                  ).toList(),
                  onSelectedItemChanged: (index) {
                    selectedPrediction = index;
                  },
                ),
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
                      completer.complete("null");
                    },
                  ),
                  DialogButton(
                    text: 'Change',
                    color: Colors.green,
                    onPressed: () async {
                      completer.complete(
                          ResNetModelHelper().classLabels[selectedPrediction]);
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );

    return completer.future;
  }
}
