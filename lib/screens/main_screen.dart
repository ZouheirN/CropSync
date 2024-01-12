import 'package:cropsync/screens/profile_screen.dart';
import 'package:cropsync/screens/quick_disease_detection_screen.dart';
import 'package:flutter/material.dart';

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

  final screens = [
    const HomeScreen(),
    const CropsScreen(),
    const QuickDiseaseDetectionScreen(),
    const DevicesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: index,
        onDestinationSelected: (index) => setState(() => this.index = index),
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
    );
  }
}
