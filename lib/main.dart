import 'package:cropsync/screens/main_screen.dart';
import 'package:cropsync/screens/welcome_screen.dart';
import 'package:cropsync/services/user_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:watch_it/watch_it.dart';

import 'json/user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter<User>(UserAdapter());
  var userInfoBox = await Hive.openBox('userInfo');

  registerManagers();

  bool isUserLoggedIn = false;

  if (userInfoBox.get('user') != null) {
    final user = userInfoBox.get('user') as User;
    di<UserModel>().user = user;
    isUserLoggedIn = true;
  }

  runApp(
    MyApp(
      isUserLoggedIn: isUserLoggedIn,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isUserLoggedIn;

  const MyApp({super.key, required this.isUserLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF57CC99),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF57CC99),
        ),
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: isUserLoggedIn ? const MainScreen() : const WelcomeScreen(),
    );
  }
}

void registerManagers() {
  di.registerSingleton<UserModel>(UserModel());
}
