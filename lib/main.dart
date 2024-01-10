import 'package:cropsync/json/user.dart';
import 'package:cropsync/screens/main_screen.dart';
import 'package:cropsync/screens/welcome_screen.dart';
import 'package:cropsync/services/user_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:watch_it/watch_it.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterMapTileCaching.initialise();
  await FMTC.instance('mapStore').manage.createAsync();

  await Hive.initFlutter();
  Hive.registerAdapter<User>(UserAdapter());
  var userInfoBox = await Hive.openBox('userInfo');
  var userPrefsBox = await Hive.openBox('userPrefs');

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
      darkModeEnabled: userPrefsBox.get('darkModeEnabled') ?? false,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isUserLoggedIn;
  final bool darkModeEnabled;

  static late ValueNotifier<ThemeMode> themeNotifier;

  const MyApp(
      {super.key, required this.isUserLoggedIn, required this.darkModeEnabled});

  @override
  Widget build(BuildContext context) {
    themeNotifier = ValueNotifier(
        darkModeEnabled == true ? ThemeMode.dark : ThemeMode.light);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
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
          themeMode: currentMode,
          debugShowCheckedModeBanner: false,
          home: isUserLoggedIn ? const MainScreen() : const WelcomeScreen(),
        );
      },
    );
  }
}

void registerManagers() {
  di.registerSingleton<UserModel>(UserModel());
}
