import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/textfields.dart';
import 'package:fancy_password_field/fancy_password_field.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final FancyPasswordController _passwordValidatorController =
      FancyPasswordController();
  final _confirmPasswordTextController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _passwordValidatorController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_formKey.currentState!.validate()) {
      if (_isLoading) return;

      setState(() {
        _isLoading = true;
      });

      // Hash the password
      final String hashedPassword = BCrypt.hashpw(
        _passwordTextController.text,
        BCrypt.gensalt(
          secureRandom: Random(
            _passwordTextController.text.length,
          ),
        ),
      );

      setState(() {
        _isLoading = false;
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
            key: _formKey,
            child: Column(
              children: [
                _buildFullNameTextInputField(),
                _buildEmailTextInputField(),
                _buildPasswordTextInputField(),
                _buildConfirmPasswordTextInputField(),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Full Name Text Input Field
  Widget _buildFullNameTextInputField() {
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
          textController: _fullNameTextController,
          prefixIcon: const Icon(Icons.person),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        const Gap(20),
      ],
    );
  }

  // Email Text Input Field
  Widget _buildEmailTextInputField() {
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
          textController: _emailTextController,
          prefixIcon: const Icon(Icons.email),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            return null;
          },
        ),
        const Gap(20),
      ],
    );
  }

  // Password Text Input Field
  Widget _buildPasswordTextInputField() {
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
          controller: _passwordTextController,
          passwordController: _passwordValidatorController,
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

            return _passwordValidatorController.areAllRulesValidated
                ? null
                : 'Please validate all rules';
          },
          validationRuleBuilder: (rules, value) {
            return SizedBox(
              height: 120,
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
                        const SizedBox(width: 8),
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
  Widget _buildConfirmPasswordTextInputField() {
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
          textController: _confirmPasswordTextController,
          prefixIcon: const Icon(Icons.lock),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password again';
            }

            if (value != _passwordTextController.text) {
              return 'Password does not match';
            }

            return null;
          },
        ),
        const Gap(20),
      ],
    );
  }

  // Register Button
  Widget _buildRegisterButton() {
    return PrimaryButton(
      text: 'Register',
      onPressed: _register,
      isLoading: _isLoading,
    );
  }
}
