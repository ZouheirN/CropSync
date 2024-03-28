import 'package:cropsync/json/crop_chart.dart';
import 'package:cropsync/json/device.dart';
import 'package:cropsync/json/device_camera.dart';
import 'package:cropsync/json/weather.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/models/crop_chart_model.dart';
import 'package:cropsync/models/device_camera_model.dart';
import 'package:cropsync/models/devices_model.dart';
import 'package:cropsync/models/weather_model.dart';
import 'package:cropsync/services/device_api.dart';
import 'package:cropsync/services/weather_api.dart';
import 'package:cropsync/utils/user_prefs.dart';
import 'package:cropsync/widgets/buttons.dart';
import 'package:cropsync/widgets/cards.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:watch_it/watch_it.dart';

class HomeScreen extends WatchingStatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final overviewPageController =
      PageController(viewportFraction: 0.8, keepPage: true);
  final deviceCameraPageController =
      PageController(viewportFraction: 0.8, keepPage: true);
  final cropLineChartsPageController =
      PageController(viewportFraction: 0.8, keepPage: true);

  Future refresh() async {
    final devices = await DeviceApi.getDevices();
    if (devices.runtimeType == List<Device>) {
      di<DevicesModel>().devices = devices;
      logger.d('Fetched Devices by Refresh');
    }

    final weatherData = await WeatherApi.getWeatherData();
    if (weatherData.runtimeType == List<Weather>) {
      di<WeatherModel>().weather = weatherData;
      logger.d('Fetched Weather by Refresh');
    }

    final deviceCameraData = await DeviceApi.getDeviceCamera();
    if (deviceCameraData.runtimeType == List<DeviceCamera>) {
      di<DeviceCameraModel>().deviceCamera = deviceCameraData;
      logger.d('Fetched Device Camera by Refresh');
    }

    final cropCharts = await DeviceApi.getCropChartData();
    if (cropCharts.runtimeType == CropChart) {
      di<CropChartModel>().cropCharts = cropCharts;
      logger.d('Fetched Crop Charts by Refresh');
    }
  }

  @override
  Widget build(BuildContext context) {
    final devices = watchPropertyValue((DevicesModel d) => d.devices.toList());
    final weather = watchPropertyValue((WeatherModel w) => w.weather.toList());
    final deviceCamera =
        watchPropertyValue((DeviceCameraModel dc) => dc.deviceCamera.toList());
    final cropCharts = watchPropertyValue((CropChartModel cc) => cc.cropCharts);

    final weatherPages = weather
        .map(
          (e) => WeatherCard(
            context: context,
            isTappable: true,
            weather: e,
          ),
        )
        .toList();

    final deviceCameraPages = deviceCamera
        .map(
          (e) => DeviceCameraCard(
            deviceCamera: e,
            context: context,
          ),
        )
        .toList();

    final cropLineChartsPages = cropCharts.data == null
        ? []
        : cropCharts.data!
            .map(
              (e) => CropLineChartCard(
                deviceName: e.deviceName!,
                cropName: e.cropName!,
                location: e.location!,
                nitrogen: e.nitrogen!,
                phosphorus: e.phosphorus!,
                moisture: e.moisture!,
                temperature: e.temperature!,
                ph: e.ph!,
                potassium: e.potassium!,
              ),
            )
            .toList();

    // final weatherAlerts = weather
    //     .map((e) {
    //       if (e.alerts == null || e.alerts!.isEmpty) return null;
    //       return {
    //         'device': e.deviceName,
    //         'location': e.location,
    //         'alert': e.alerts,
    //       };
    //     })
    //     .toList()
    //     .where((element) => element != null)
    //     .toList();

    final weatherAlerts = List.generate(0, (index) => null);

    final homeListItems = watchPropertyValue((UserPrefs u) => u.homeListItems);

    return Visibility(
      visible: devices.isNotEmpty,
      replacement: noDeviceAdded(),
      child: SafeArea(
        child: AnimationLimiter(
          child: RefreshIndicator(
            onRefresh: refresh,
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
                    for (var item in homeListItems)
                      if (item == 'Weather')
                        buildWeather(weatherPages)
                      else if (item == 'Alerts')
                        buildAlerts(weatherAlerts)
                      else if (item == 'Device Camera')
                        buildDeviceCamera(deviceCameraPages)
                      else if (item == 'Statistics')
                        buildStatistics(cropLineChartsPages),
                    const Gap(20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Weather
  Widget buildWeather(pages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weather',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.wb_cloudy_rounded,
                color: Colors.blue,
              ),
            ],
          ),
        ),
        const Gap(16),
        SizedBox(
          height: 300,
          child: Visibility(
            visible: pages.isNotEmpty,
            replacement: const Center(
              child: CircularProgressIndicator(),
              // child: Shimmer.fromColors(
              //   baseColor: Colors.grey[300]!,
              //   highlightColor: Colors.grey[100]!,
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 38,
              //       vertical: 16,
              //     ),
              //     child: Container(
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(16),
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              // ),
            ),
            child: PageView.builder(
              controller: overviewPageController,
              itemCount: pages.length,
              itemBuilder: (_, index) {
                return pages[index % pages.length];
              },
            ),
          ),
        ),
        if (pages.isNotEmpty && pages.length > 1)
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
  Widget buildAlerts(List<Map<String, Object?>?> weatherAlerts) {
    if (weatherAlerts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alerts',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.notifications_rounded,
                color: Colors.red,
              ),
            ],
          ),
          for (var alert in weatherAlerts)
            ExpansionTileCard(
              title: Text(
                  '${alert!['device']} (${(alert['alert'] as List<String>).length} ${(alert['alert'] as List<String>).length == 1 ? 'Alert' : 'Alerts'})'),
              children: [
                ListTile(
                  title: Text(alert['location'].toString()),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var a in alert['alert'] as List<String>)
                        Text(
                          a,
                          style: const TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Device Camera
  Widget buildDeviceCamera(pages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Device Camera',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.camera_alt_rounded,
                color: Colors.green,
              ),
            ],
          ),
        ),
        const Gap(16),
        SizedBox(
          width: double.infinity,
          height: 280,
          child: Visibility(
            visible: pages.isNotEmpty,
            replacement: const Center(
              child: CircularProgressIndicator(),
            ),
            child: PageView.builder(
              controller: deviceCameraPageController,
              itemCount: pages.length,
              itemBuilder: (_, index) {
                return pages[index % pages.length];
              },
            ),
          ),
        ),
        if (pages.isNotEmpty && pages.length > 1)
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

  // Statistics
  Widget buildStatistics(pages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistics',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.bar_chart_rounded,
                color: Colors.orange,
              ),
            ],
          ),
        ),
        const Gap(16),
        SizedBox(
          width: double.infinity,
          height: 426,
          child: Visibility(
            visible: pages.isNotEmpty,
            replacement: const Center(
              child: CircularProgressIndicator(),
            ),
            child: PageView.builder(
              controller: cropLineChartsPageController,
              itemCount: pages.length,
              itemBuilder: (_, index) {
                return pages[index % pages.length];
              },
            ),
          ),
        ),
        if (pages.isNotEmpty && pages.length > 1)
          Column(
            children: [
              const Gap(16),
              Container(
                alignment: Alignment.center,
                child: SmoothPageIndicator(
                  controller: cropLineChartsPageController,
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
            ),
          ],
        ),
      ),
    );
  }
}
