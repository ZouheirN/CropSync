import 'dart:math';
import 'dart:ui';

import 'package:bcrypt/bcrypt.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/services/user_api.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:cropsync/utils/curve.dart';
import 'package:cropsync/utils/other_variables.dart';
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
  bool isObscure = true;
  Text status = const Text("");

  Future<void> login() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (formKey.currentState!.validate()) {
      if (isLoading) return;

      setState(() {
        isLoading = true;
        status = const Text("");
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

      final user = await UserApi.login(
        email: emailTextController.text,
        password: hashedPassword,
      );

      if (user == ReturnTypes.fail) {
        setState(() {
          isLoading = false;
          status = const Text(
            "Invalid email or password",
            style: TextStyle(color: Colors.red),
          );
        });
        return;
      } else if (user == ReturnTypes.error) {
        setState(() {
          isLoading = false;
          status = const Text(
            "An error occurred, try again",
            style: TextStyle(color: Colors.red),
          );
        });
        return;
      }

      setState(() {
        isLoading = false;
        status = const Text("");
      });

      if (!user.isVerified!) {
        if (!mounted) return;
        Navigator.of(context).pushNamed(
          '/otp',
          arguments: {
            'email': user.email,
            'token': user.token,
            'isNotVerifiedFromLogin': true,
          },
        );
      } else {
        di<UserModel>().user = user;
        if (!context.mounted) return;
        OtherVars().autoRefresh = true;
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }
    }
  }

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: Alignment.bottomRight,
        fit: StackFit.expand,
        children: [
          ClipPath(
            clipper: ImageClipper(),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
              child: Image.asset(
                'assets/images/leaves.jpg',
                alignment: Alignment.topCenter,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Positioned(
            top: 40.0,
            left: 20.0,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20.0,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.black,
                  size: 24.0,
                ),
              ),
            ),
          ),
          Positioned(
            height: MediaQuery.of(context).size.height * 0.67,
            width: MediaQuery.of(context).size.width,
            child: Scaffold(
              body: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Welcome Back',
                                      style: TextStyle(
                                        fontSize: 32.0,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  Text('Login to your account',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15.0,
                                      ))
                                ],
                              ),
                            ),
                            Column(
                                children: [
                                  buildEmailTextInputField(),
                                  const Gap(20),
                                  buildPasswordTextInputField(),
                                ],
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
                            if (status.data != "")
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: status,
                              ),
                            buildLoginButton(),
                            const Gap(20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Don\'t have an account? '),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushReplacementNamed('/register');
                                  },
                                  child: const Text(
                                    'Register',
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
        ],
      ),
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
          textInputAction: TextInputAction.next,
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
        PrimaryTextField(
          hintText: 'Password',
          textController: passwordTextController,
          prefixIcon: const Icon(Icons.lock_rounded),
          obscureText: isObscure,
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                setState(() {
                  isObscure = !isObscure;
                });
              },
              icon: Icon(
                isObscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
              ),
            ),
          ),
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
  Widget buildLoginButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: CommonButton(
        text: 'Login',
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Colors.white,
        onPressed: login,
        isLoading: isLoading,
      ),
    );
  }
}
