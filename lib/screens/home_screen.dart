import 'package:cropsync/main.dart';
import 'package:cropsync/models/device_camera_model.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/models/weather_model.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/device_camera_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:watch_it/watch_it.dart';

import '../widgets/overview_card.dart';

class HomeScreen extends WatchingStatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final overviewPageController = PageController(viewportFraction: 0.8, keepPage: true);
  final deviceCameraPageController = PageController(viewportFraction: 0.8, keepPage: true);

  @override
  Widget build(BuildContext context) {
    final devices = watchPropertyValue((UserModel m) => m.user.devices);
    final weather = watchPropertyValue((WeatherModel w) => w.weather);
    final deviceCamera = watchPropertyValue((DeviceCameraModel dc) => dc.deviceCamera);

    final overviewPages = weather.map((e) => overviewCard(e)).toList();
    final deviceCameraPages = deviceCamera.map((e) => deviceCameraCard(e)).toList();

    if (devices!.isEmpty) return noDeviceAdded();

    return SafeArea(
      child: AnimationLimiter(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [
                buildOverview(overviewPages),
                const Gap(20),
                // buildAlerts(),
                // const Gap(20),
                buildDeviceCamera(deviceCameraPages),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Overview
  Widget buildOverview(pages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Text(
            'Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const Gap(16),
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: overviewPageController,
            itemCount: pages.length,
            itemBuilder: (_, index) {
              return pages[index % pages.length];
            },
          ),
        ),
        if (pages.isNotEmpty)
          Column(
            children: [
              const Gap(16),
              Container(
                alignment: Alignment.center,
                child: SmoothPageIndicator(
                  controller: overviewPageController,
                  count: pages.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 16,
                    dotWidth: 16,
                    activeDotColor: MyApp.themeNotifier.value == ThemeMode.light
                        ? const Color(0xFF202C26)
                        : const Color(0xFFE3EDE7),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // Alerts
  Widget buildAlerts() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Text(
            'Alerts',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Device Camera
  Widget buildDeviceCamera(pages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Text(
            'Device Camera',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const Gap(16),
        SizedBox(
          width: double.infinity,
          height: 280,
          child: PageView.builder(
            controller: deviceCameraPageController,
            itemCount: pages.length,
            itemBuilder: (_, index) {
              return pages[index % pages.length];
            },
          ),
        ),
        if (pages.isNotEmpty)
          Column(
            children: [
              const Gap(16),
              Container(
                alignment: Alignment.center,
                child: SmoothPageIndicator(
                  controller: deviceCameraPageController,
                  count: pages.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 16,
                    dotWidth: 16,
                    activeDotColor: MyApp.themeNotifier.value == ThemeMode.light
                        ? const Color(0xFF202C26)
                        : const Color(0xFFE3EDE7),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // No Device Added
  Widget noDeviceAdded() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You do not have any devices added. Please add a device.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const Gap(16),
            CommonButton(
              text: 'Add a Device',
              backgroundColor: Theme.of(context).primaryColor,
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed('/add-device');
              },
            )
          ],
        ),
      ),
    );
  }
}
