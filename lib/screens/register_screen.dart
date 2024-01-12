import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:cropsync/screens/login_screen.dart';
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

  @override
  void dispose() {
    passwordValidatorController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (formKey.currentState!.validate()) {
      if (isLoading) return;

      setState(() {
        isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      // Hash the password
      final String hashedPassword = BCrypt.hashpw(
        passwordTextController.text,
        BCrypt.gensalt(
          secureRandom: Random(
            passwordTextController.text.length,
          ),
        ),
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                buildFullNameTextInputField(),
                const Gap(20),
                buildEmailTextInputField(),
                const Gap(20),
                buildPasswordTextInputField(),
                const Gap(20),
                buildConfirmPasswordTextInputField(),
                const Gap(20),
                buildRegisterButton(),
                const Gap(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Full Name Text Input Field
  Widget buildFullNameTextInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Full Name',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(10),
        PrimaryTextField(
          hintText: 'Enter your full name',
          textController: fullNameTextController,
          prefixIcon: const Icon(Icons.person),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }

            RegExp nameRegex =
                RegExp(r"^[A-Z][a-zA-Z]{3,}(?: [A-Z][a-zA-Z]*){0,2}$");
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
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(10),
        PrimaryTextField(
          hintText: 'Enter your email',
          textController: emailTextController,
          prefixIcon: const Icon(Icons.email),
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
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
                          ruleValidated ? Icons.check : Icons.close,
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
            prefixIcon: Icon(Icons.lock),
            // fillColor: ,
            hintText: 'Enter your password',
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
        const Text(
          'Confirm Password',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(10),
        PrimaryTextField(
          hintText: 'Enter your password again',
          textController: confirmPasswordTextController,
          prefixIcon: const Icon(Icons.lock),
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
