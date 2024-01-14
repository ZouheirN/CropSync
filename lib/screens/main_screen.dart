import 'dart:async';

import 'package:cropsync/json/device_camera.dart';
import 'package:cropsync/json/weather.dart';
import 'package:cropsync/models/device_camera_model.dart';
import 'package:cropsync/models/weather_model.dart';
import 'package:cropsync/screens/profile_screen.dart';
import 'package:cropsync/screens/quick_disease_detection_screen.dart';
import 'package:cropsync/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:logger/logger.dart';
import 'package:watch_it/watch_it.dart';

import 'crops_screen.dart';
import 'devices_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;
  bool pauseData = false;

  void weather() async {
    final weatherData = await ApiRequests.getWeatherData();
    final weather = weatherFromJson(weatherData);
    di<WeatherModel>().weather = weather;
    Logger().d('Fetched Weather');

    Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (pauseData == true) return;

      final weatherData = await ApiRequests.getWeatherData();
      final weather = weatherFromJson(weatherData);
      di<WeatherModel>().weather = weather;
      Logger().d('Fetched Weather');
    });
  }

  void deviceCamera() async {
    final deviceCameraData = await ApiRequests.getDeviceCamera();
    final deviceCamera = deviceCameraFromJson(deviceCameraData);
    di<DeviceCameraModel>().deviceCamera = deviceCamera;
    Logger().d('Fetched Device Camera');

    Timer.periodic(const Duration(minutes: 2), (timer) async {
      if (pauseData == true) return;

      final deviceCameraData = await ApiRequests.getDeviceCamera();
      final deviceCamera = deviceCameraFromJson(deviceCameraData);
      di<DeviceCameraModel>().deviceCamera = deviceCamera;
      Logger().d('Fetched Device Camera');
    });
  }

  @override
  void initState() {
    // Initialize Periodic Timers
    weather();
    deviceCamera();
    super.initState();
  }

  final screens = [
    const HomeScreen(),
    const CropsScreen(),
    const QuickDiseaseDetectionScreen(),
    const DevicesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return FGBGNotifier(
      onEvent: (event) {
        if (event == FGBGType.background) {
          Logger().d('Paused Fetching');
          pauseData = true;
        } else {
          Logger().d('Resumed Fetching');
          pauseData = false;
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
              icon: const Icon(Icons.home_rounded),
              label: 'Home',
              selectedIcon: Icon(
                Icons.home_rounded,
                color: Theme.of(context).primaryColor,
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
