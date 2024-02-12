import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/services/user_api.dart';
import 'package:cropsync/services/user_token.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/textfields.dart';
import 'package:fancy_password_field/fancy_password_field.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:logger/logger.dart';
import 'package:watch_it/watch_it.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final FancyPasswordController passwordValidatorController =
      FancyPasswordController();
  String status = '';
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  Future<void> submit() async {
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    final forgotPassword = arg['forgotPassword'] ?? false;

    if (_formKey.currentState!.validate()) {
      if (isLoading) return;

      setState(() {
        isLoading = true;
        status = '';
      });

      if (forgotPassword) {
        final newPassword = newPasswordController.text;
        final String hashedNewPassword = BCrypt.hashpw(newPassword,
            BCrypt.gensalt(secureRandom: Random(newPassword.length)));

        final result = await UserApi.resetPassword(
            password: hashedNewPassword, token: arg['token']);

        if (result == ReturnTypes.fail) {
          setState(() {
            status = 'An error occurred. Please try again';
            isLoading = false;
          });
        } else if (result == ReturnTypes.error) {
          setState(() {
            status = 'An error occurred. Please try again';
            isLoading = false;
          });
        } else if (result == ReturnTypes.invalidToken) {
          if (!mounted) return;
          invalidTokenResponse(context);
        }

        Logger().d(result);

        UserToken.setToken(result.token);
        di<UserModel>().user = result;

        setState(() {
          isLoading = false;
        });

        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      } else {
        final oldPassword = oldPasswordController.text;
        final newPassword = newPasswordController.text;

        // Hash the passwords
        final String hashedOldPassword = BCrypt.hashpw(oldPassword,
            BCrypt.gensalt(secureRandom: Random(oldPassword.length)));

        final String hashedNewPassword = BCrypt.hashpw(newPassword,
            BCrypt.gensalt(secureRandom: Random(newPassword.length)));

        final result = await UserApi.changePassword(
          oldPassword: hashedOldPassword,
          newPassword: hashedNewPassword,
        );

        if (result == ReturnTypes.fail) {
          setState(() {
            status = 'An error occurred. Please try again';
            isLoading = false;
          });
          return;
        } else if (result == ReturnTypes.error) {
          setState(() {
            status = 'An error occurred. Please try again';
            isLoading = false;
          });
          return;
        } else if (result == ReturnTypes.invalidPassword) {
          setState(() {
            status = 'Invalid Password';
            isLoading = false;
          });
          return;
        } else if (result == ReturnTypes.invalidToken) {
          if (!mounted) return;
          invalidTokenResponse(context);
          return;
        }

        Logger().d(result);

        UserToken.setToken(result.token);
        di<UserModel>().user = result;

        setState(() {
          status = 'Password Changed Successfully!';
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    passwordValidatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    final forgotPassword = arg['forgotPassword'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        centerTitle: true,
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(top: 50, bottom: 16, right: 16, left: 16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!forgotPassword)
                  const Text(
                    'Old Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                if (!forgotPassword) const Gap(10),
                if (!forgotPassword)
                  PrimaryTextField(
                    textController: oldPasswordController,
                    hintText: 'Enter your old password',
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your old password';
                      }
                      return null;
                    },
                  ),
                if (!forgotPassword) const Gap(20),
                const Text(
                  'New Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Gap(10),
                FancyPasswordField(
                  hidePasswordIcon: const Icon(
                    Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                  showPasswordIcon: const Icon(
                    Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  controller: newPasswordController,
                  passwordController: passwordValidatorController,
                  validationRules: {
                    DigitValidationRule(),
                    UppercaseValidationRule(),
                    LowercaseValidationRule(),
                    MinCharactersValidationRule(8),
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your new password';
                    }

                    return passwordValidatorController.areAllRulesValidated
                        ? null
                        : 'Please validate all rules';
                  },
                  validationRuleBuilder: (rules, value) {
                    return SizedBox(
                      child: ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: rules.map(
                          (rule) {
                            final ruleValidated = rule.validate(value);
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  ruleValidated ? Icons.check_rounded : Icons.close_rounded,
                                  color:
                                      ruleValidated ? Colors.green : Colors.red,
                                ),
                                const Gap(8),
                                Text(
                                  rule.name,
                                  style: TextStyle(
                                    color: ruleValidated
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                )
                              ],
                            );
                          },
                        ).toList(),
                      ),
                    );
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    filled: true,
                    hintText: 'Enter your new password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      borderSide: BorderSide(
                        color: Color(0xFFDEE3EB),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                const Gap(20),
                const Text(
                  'Confirm Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Gap(10),
                PrimaryTextField(
                  obscureText: true,
                  textController: confirmPasswordController,
                  hintText: 'Confirm your new password',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const Gap(20),
                CommonButton(
                  text: 'Change',
                  textColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  onPressed: submit,
                  isLoading: isLoading,
                ),
                const Gap(20),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: status == "Password Changed Successfully!"
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
