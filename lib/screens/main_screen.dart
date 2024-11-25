import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:cropsync/json/crop_chart.dart';
import 'package:cropsync/json/device.dart';
import 'package:cropsync/json/device_camera.dart';
import 'package:cropsync/json/weather.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/models/crop_chart_model.dart';
import 'package:cropsync/models/device_camera_model.dart';
import 'package:cropsync/models/devices_model.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/models/weather_model.dart';
import 'package:cropsync/screens/profile_screen.dart';
import 'package:cropsync/screens/quick_disease_detection_screen.dart';
import 'package:cropsync/services/device_api.dart';
import 'package:cropsync/services/resnet_model_helper.dart';
import 'package:cropsync/services/weather_api.dart';
import 'package:cropsync/utils/other_variables.dart';
import 'package:cropsync/utils/user_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:watch_it/watch_it.dart';

import 'crops_screen.dart';
import 'devices_screen.dart';
import 'home_screen.dart';

class MainScreen extends WatchingStatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = di<UserPrefs>().startPage == 'Home'
      ? 0
      : di<UserPrefs>().startPage == 'Crops'
          ? 1
          : di<UserPrefs>().startPage == 'Camera'
              ? 2
              : di<UserPrefs>().startPage == 'Devices'
                  ? 3
                  : 4;

  late DateTime exitTime;

  final quickActions = const QuickActions();

  final screens = [
    const HomeScreen(),
    const CropsScreen(),
    const QuickDiseaseDetectionScreen(),
    const DevicesScreen(),
    const ProfileScreen(),
  ];

  void weather({bool onlyOnce = false}) async {
    final weatherData = await WeatherApi.getWeatherData();
    if (weatherData.runtimeType == List<Weather>) {
      di<WeatherModel>().weather = weatherData;
      logger.t('Fetched Weather');
    }
    if (onlyOnce) return;

    Timer.periodic(const Duration(minutes: 15), (timer) async {
      if (!di<OtherVars>().autoRefresh) return;

      final weatherData = await WeatherApi.getWeatherData();
      if (weatherData.runtimeType == List<Weather>) {
        di<WeatherModel>().weather = weatherData;
        logger.t('Fetched Weather');
      }
    });
  }

  void deviceCamera({bool onlyOnce = false}) async {
    final deviceCameraData = await DeviceApi.getDeviceCamera();
    if (deviceCameraData.runtimeType == List<DeviceCamera>) {
      di<DeviceCameraModel>().deviceCamera = deviceCameraData;
      logger.t('Fetched Device Camera');
    }
    if (onlyOnce) return;

    Timer.periodic(const Duration(minutes: 20), (timer) async {
      if (!di<OtherVars>().autoRefresh) return;

      final deviceCameraData = await DeviceApi.getDeviceCamera();
      if (deviceCameraData.runtimeType == List<DeviceCamera>) {
        di<DeviceCameraModel>().deviceCamera = deviceCameraData;
        logger.t('Fetched Device Camera');
      }
    });
  }

  void devices({bool onlyOnce = false}) async {
    final devices = await DeviceApi.getDevices();
    if (devices.runtimeType == List<Device>) {
      di<DevicesModel>().devices = devices;
      logger.t('Fetched Devices');
    }
    if (onlyOnce) return;

    Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (!di<OtherVars>().autoRefresh) return;

      final devices = await DeviceApi.getDevices();
      if (devices.runtimeType == List<Device>) {
        di<DevicesModel>().devices = devices;
        logger.t('Fetched Devices');
      }
    });
  }

  void cropCharts({bool onlyOnce = false}) async {
    final weeklyCropCharts = await DeviceApi.getWeeklyCropChartData();
    if (weeklyCropCharts.runtimeType == CropChart) {
      di<CropChartModel>().weeklyCropCharts = weeklyCropCharts;
      logger.t('Fetched Weekly Crop Charts');
    }

    final monthlyCropCharts = await DeviceApi.getMonthlyCropChartData();
    if (monthlyCropCharts.runtimeType == CropChart) {
      di<CropChartModel>().monthlyCropCharts = monthlyCropCharts;
      logger.t('Fetched Monthly Crop Charts');
    }
    if (onlyOnce) return;

    Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (!di<OtherVars>().autoRefresh) return;

      final weeklyCropCharts = await DeviceApi.getWeeklyCropChartData();
      if (weeklyCropCharts.runtimeType == CropChart) {
        di<CropChartModel>().weeklyCropCharts = weeklyCropCharts;
        logger.t('Fetched Weekly Crop Charts');
      }

      final monthlyCropCharts = await DeviceApi.getMonthlyCropChartData();
      if (monthlyCropCharts.runtimeType == CropChart) {
        di<CropChartModel>().monthlyCropCharts = monthlyCropCharts;
        logger.t('Fetched Monthly Crop Charts');
      }
    });
  }

  @override
  void initState() {
    // If timers are not running, initialize them
    if (di<OtherVars>().autoRefresh == true) {
      weather();
      deviceCamera();
      devices();
      cropCharts();
      //userInfo(); todo
    }

    quickActions.setShortcutItems([
      const ShortcutItem(
        type: 'camera',
        localizedTitle: 'Camera',
        icon: 'icon_camera',
      ),
      const ShortcutItem(
        type: 'gemini-camera',
        localizedTitle: 'Camera (Gemini AI)',
        icon: 'icon_gemini',
      ),
    ]);
    quickActions.initialize((shortcutType) {
      if (shortcutType == 'camera' || shortcutType == 'gemini-camera') {
        if (di<UserModel>().user.token == null) {
          return;
        }

        setState(() => index = 2);

        // open camera
        ResNetModelHelper()
            .pickImage(ImageSource.camera, isLocal: shortcutType == 'camera');
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final showBadge = watchPropertyValue((OtherVars o) => o.showBadge);

    return FGBGNotifier(
      onEvent: (event) async {
        if (event == FGBGType.background) {
          logger.d('Paused Fetching');
          di<OtherVars>().autoRefresh = false;

          // save exit time
          exitTime = DateTime.now();
        } else {
          await Future.delayed(const Duration(seconds: 2));
          logger.d('Resumed Fetching');
          di<OtherVars>().autoRefresh = true;

          // check if 5 minutes have passed
          if (DateTime.now().difference(exitTime).inMinutes >= 5) {
            weather(onlyOnce: true);
            deviceCamera(onlyOnce: true);
            devices(onlyOnce: true);
            cropCharts(onlyOnce: true);
          }
        }
      },
      child: Scaffold(
        body: screens[index],
        bottomNavigationBar: NavigationBar(
          height: 70,
          selectedIndex: index,
          onDestinationSelected: (index) => setState(() => this.index = index),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: [
            NavigationDestination(
              icon: badges.Badge(
                showBadge: showBadge,
                position: badges.BadgePosition.topEnd(top: -3, end: -3),
                badgeAnimation: const badges.BadgeAnimation.scale(),
                child: const Icon(Icons.home_rounded),
              ),
              label: 'Home',
              selectedIcon: badges.Badge(
                showBadge: showBadge,
                position: badges.BadgePosition.topEnd(top: -3, end: -3),
                badgeAnimation: const badges.BadgeAnimation.scale(),
                child: Icon(
                  Icons.home_rounded,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            NavigationDestination(
              icon: const Icon(Icons.grass_rounded),
              label: 'Crops',
              selectedIcon: Icon(
                Icons.grass_rounded,
                color: Theme.of(context).primaryColor,
              ),
            ),
            NavigationDestination(
              icon: const Icon(Icons.camera_rounded),
              label: 'Camera',
              selectedIcon: Icon(
                Icons.camera_rounded,
                color: Theme.of(context).primaryColor,
              ),
            ),
            NavigationDestination(
              icon: const Icon(Icons.device_hub_rounded),
              label: 'Devices',
              selectedIcon: Icon(
                Icons.device_hub_rounded,
                color: Theme.of(context).primaryColor,
              ),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_rounded),
              label: 'Profile',
              selectedIcon: Icon(
                Icons.person_rounded,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
