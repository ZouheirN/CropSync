import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:cropsync/json/user.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/screens/register_screen.dart';
import 'package:cropsync/services/http_requests.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:cropsync/widgets/textfields.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:watch_it/watch_it.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  bool isLoading = false;

  Future<void> _login() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (formKey.currentState!.validate()) {
      if (isLoading) return;

      setState(() {
        isLoading = true;
      });

      // Hash the password
      final String hashedPassword = BCrypt.hashpw(
        passwordTextController.text,
        BCrypt.gensalt(
          secureRandom: Random(
            passwordTextController.text.length,
          ),
        ),
      );

      // TODO get user info from api
      final userData = await ApiRequests.checkCredentials(
        emailTextController.text,
        hashedPassword,
      );
      User user = userFromJson(userData);
      di<UserModel>().user = user;

      setState(() {
        isLoading = false;
      });

      if (!user.isVerified!) {
        if (!mounted) return;
        Navigator.of(context).pushNamed(
          '/otp',
          arguments: {
            'email': user.email,
            'isNotVerifiedFromLogin': true,
          },
        );
      } else {
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
                AutofillGroup(
                  child: Column(
                    children: [
                      _buildEmailTextInputField(),
                      const Gap(20),
                      _buildPasswordTextInputField(),
                    ],
                  ),
                ),
                const Gap(10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Dialogs.showForgotPasswordDialog(context);
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
                const Gap(10),
                _buildLoginButton(),
                const Gap(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Don\'t have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Register',
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
          textController: emailTextController,
          prefixIcon: const Icon(Icons.email),
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
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
        PrimaryTextField(
          hintText: 'Enter your password',
          textController: passwordTextController,
          prefixIcon: const Icon(Icons.lock),
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          onEditingComplete: () => TextInput.finishAutofillContext(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }

            return null;
          },
        ),
      ],
    );
  }

  // Login Button
  Widget _buildLoginButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: CommonButton(
        text: 'Login',
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Colors.white,
        onPressed: _login,
        isLoading: isLoading,
      ),
    );
  }
}
