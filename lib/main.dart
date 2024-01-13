import 'package:cropsync/json/image.dart';
import 'package:cropsync/json/user.dart';
import 'package:cropsync/json/weather.dart';
import 'package:cropsync/models/image_model.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/models/weather_model.dart';
import 'package:cropsync/screens/account_information_screen.dart';
import 'package:cropsync/screens/add_device_map_screen.dart';
import 'package:cropsync/screens/add_device_screen.dart';
import 'package:cropsync/screens/login_screen.dart';
import 'package:cropsync/screens/main_screen.dart';
import 'package:cropsync/screens/otp_screen.dart';
import 'package:cropsync/screens/register_screen.dart';
import 'package:cropsync/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:watch_it/watch_it.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterMapTileCaching.initialise();
  await FMTC.instance('mapStore').manage.createAsync();

  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter<User>(UserAdapter());
  Hive.registerAdapter<Devices>(DevicesAdapter());
  Hive.registerAdapter<Crop>(CropAdapter());
  Hive.registerAdapter<Weather>(WeatherAdapter());
  Hive.registerAdapter<ImageObject>(ImageObjectAdapter());

  var userInfoBox = await Hive.openBox('userInfo');
  var userPrefsBox = await Hive.openBox('userPrefs');
  var imagesBox = await Hive.openBox('images');

  registerManagers();

  bool isUserLoggedIn = false;

  if (userInfoBox.get('user') != null) {
    final user = userInfoBox.get('user') as User;
    di<UserModel>().user = user;
    isUserLoggedIn = true;
  }

  if (imagesBox.isNotEmpty) {
    final images = imagesBox.values.toList().cast<ImageObject>();
    di<ImageModel>().images.addAll(images);
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

  const MyApp({
    super.key,
    required this.isUserLoggedIn,
    required this.darkModeEnabled,
  });

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
          routes: {
            '/': (context) => isUserLoggedIn
                ? const MainScreen()
                : const WelcomeScreen(),
            '/main': (context) => const MainScreen(),
            '/welcome': (context) => const WelcomeScreen(),
            '/register': (context) => const RegisterScreen(),
            '/login': (context) => const LoginScreen(),
            '/add-device': (context) => const AddDeviceScreen(),
            '/add-device-map': (context) => const AddDeviceMapScreen(),
            '/account-information': (context) => const AccountInformationScreen(),
            '/otp': (context) => const OTPScreen(),
          }
        );
      },
    );
  }
}

void registerManagers() {
  di.registerSingleton<UserModel>(UserModel());
  di.registerSingleton<ImageModel>(ImageModel());
  di.registerSingleton<WeatherModel>(WeatherModel());
}
