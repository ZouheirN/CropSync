import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:cropsync/services/user_api.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/textfields.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fancy_password_field/fancy_password_field.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  final fullNameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final FancyPasswordController passwordValidatorController =
      FancyPasswordController();
  final confirmPasswordTextController = TextEditingController();

  bool isLoading = false;
  Text status = const Text("");

  @override
  void dispose() {
    passwordValidatorController.dispose();
    fullNameTextController.dispose();
    emailTextController.dispose();
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (formKey.currentState!.validate()) {
      if (isLoading) return;

      setState(() {
        isLoading = true;
        status = const Text("");
      });

      final email = emailTextController.text.trim();
      final fullName = capitalizeFirstLetterOfEachWord(
        fullNameTextController.text.trim(),
      );

      // Hash the password
      final String hashedPassword = BCrypt.hashpw(
        passwordTextController.text,
        BCrypt.gensalt(
          secureRandom: Random(
            passwordTextController.text.length,
          ),
        ),
      );

      final signUpData = await UserApi.signUp(
        fullName: fullName!,
        email: email,
        password: hashedPassword,
      );

      if (signUpData == ReturnTypes.fail) {
        setState(() {
          isLoading = false;
          status = const Text(
            "Registration failed, try again",
            style: TextStyle(color: Colors.red),
          );
        });
        return;
      }

      final token = signUpData['token'];

      setState(() {
        isLoading = false;
      });

      if (!mounted) return;
      Navigator.of(context).pushNamed('/otp', arguments: {
        'token': token,
        'email': email,
      });
    }
  }

  String? capitalizeFirstLetterOfEachWord(String? input) {
    if (input == null || input.isEmpty) {
      return input;
    }

    List<String> words = input.split(' ');

    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      }
    }

    return words.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Gap(60),
                            const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 32.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(10),
                            const Text(
                              'Create a new account',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15.0,
                              ),
                            ),
                            const Gap(60),
                            buildFullNameTextInputField(),
                            const Gap(20),
                            buildEmailTextInputField(),
                            const Gap(20),
                            buildPasswordTextInputField(),
                            const Gap(20),
                            buildConfirmPasswordTextInputField(),
                            const Gap(20),
                            if (status.data != "")
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: status,
                              ),
                            buildRegisterButton(),
                            const Gap(20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Already have an account? '),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushReplacementNamed('/login');
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40.0,
            left: 20.0,
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              radius: 20.0,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.black,
                  size: 24.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Full Name Text Input Field
  Widget buildFullNameTextInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrimaryTextField(
          hintText: 'Full Name',
          textController: fullNameTextController,
          prefixIcon: const Icon(Icons.person_rounded),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }

            RegExp nameRegex = RegExp(
                r"(^[A-Za-z]{2,16})( ?)([A-Za-z]{2,16})?( ?)?([A-Za-z]{2,16})?( ?)?([A-Za-z]{2,16})");
            if (!nameRegex.hasMatch(value.trim())) {
              return 'Please enter a valid name';
            }

            return null;
          },
        ),
      ],
    );
  }

  // Email Text Input Field
  Widget buildEmailTextInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrimaryTextField(
          hintText: 'Email',
          textController: emailTextController,
          prefixIcon: const Icon(Icons.email_rounded),
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
      ],
    );
  }

  // Password Text Input Field
  Widget buildPasswordTextInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FancyPasswordField(
          hidePasswordIcon: const Icon(
            Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          showPasswordIcon: const Icon(
            Icons.visibility_outlined,
            color: Colors.grey,
          ),
          controller: passwordTextController,
          passwordController: passwordValidatorController,
          validationRules: {
            DigitValidationRule(),
            UppercaseValidationRule(),
            LowercaseValidationRule(),
            MinCharactersValidationRule(8),
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
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
                          color: ruleValidated ? Colors.green : Colors.red,
                        ),
                        const Gap(8),
                        Text(
                          rule.name,
                          style: TextStyle(
                            color: ruleValidated ? Colors.green : Colors.red,
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
            prefixIcon: Icon(Icons.lock_rounded),
            hintText: 'Password',
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
      ],
    );
  }

  // Confirm Password Text Input Field
  Widget buildConfirmPasswordTextInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrimaryTextField(
          hintText: 'Confirm Password',
          textController: confirmPasswordTextController,
          prefixIcon: const Icon(Icons.lock_rounded),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password again';
            }

            if (value != passwordTextController.text) {
              return 'Password does not match';
            }

            return null;
          },
        ),
      ],
    );
  }

  // Register Button
  Widget buildRegisterButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: CommonButton(
        text: 'Register',
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Colors.white,
        onPressed: register,
        isLoading: isLoading,
      ),
    );
  }
}
