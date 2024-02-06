import 'package:cropsync/json/crop.dart';
import 'package:cropsync/json/device.dart';
import 'package:cropsync/json/image.dart';
import 'package:cropsync/json/user.dart';
import 'package:cropsync/models/device_camera_model.dart';
import 'package:cropsync/models/devices_model.dart';
import 'package:cropsync/models/image_model.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/models/weather_model.dart';
import 'package:cropsync/screens/account_information_screen.dart';
import 'package:cropsync/screens/add_device_map_screen.dart';
import 'package:cropsync/screens/add_device_screen.dart';
import 'package:cropsync/screens/change_password_screen.dart';
import 'package:cropsync/screens/device_camera_history_screen.dart';
import 'package:cropsync/screens/edit_device_screen.dart';
import 'package:cropsync/screens/login_screen.dart';
import 'package:cropsync/screens/main_screen.dart';
import 'package:cropsync/screens/otp_screen.dart';
import 'package:cropsync/screens/register_screen.dart';
import 'package:cropsync/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:watch_it/watch_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await FlutterMapTileCaching.initialise();
  await FMTC.instance('mapStore').manage.createAsync();

  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter<User>(UserAdapter());
  Hive.registerAdapter<ImageObject>(ImageObjectAdapter());
  Hive.registerAdapter<Device>(DeviceAdapter());
  Hive.registerAdapter<Crop>(CropAdapter());

  var userInfoBox = await Hive.openBox('userInfo');
  var userPrefsBox = await Hive.openBox('userPrefs');
  var imagesBox = await Hive.openBox('images');
  var devicesBox = await Hive.openBox('devices');

  registerManagers();

  bool isUserLoggedIn = false;

  // put user to state management
  if (userInfoBox.get('user') != null) {
    final user = userInfoBox.get('user') as User;
    di<UserModel>().user = user;
    isUserLoggedIn = true;
  }

  // put images to state management
  if (imagesBox.isNotEmpty) {
    final images = imagesBox.values.toList().cast<ImageObject>();
    di<ImageModel>().images.addAll(images);
  }

  // put devices to state management
  if (devicesBox.isNotEmpty) {
    final devices = devicesBox.get('devices');
    for (Device device in devices) {
      di<DevicesModel>().addDevice(
        id: device.deviceId!,
        name: device.name!,
        isConnected: device.isConnected!,
        location: device.location!,
        code: device.code!,
      );
    }
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
            '/edit-device': (context) => const EditDeviceScreen(),
            '/add-device-map': (context) => const AddDeviceMapScreen(),
            '/account-information': (context) => const AccountInformationScreen(),
            '/otp': (context) => const OTPScreen(),
            '/change-password': (context) => const ChangePasswordScreen(),
            '/device-camera-history': (context) => const DeviceCameraHistoryScreen(),
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
  di.registerSingleton<DeviceCameraModel>(DeviceCameraModel());
  di.registerSingleton<DevicesModel>(DevicesModel());
}
