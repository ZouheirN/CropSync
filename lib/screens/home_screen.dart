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
import 'package:cropsync/services/user_token.dart';
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

  String token = '';
  bool isWeatherRefreshing = false;
  bool isAlertsRefreshing = false;
  bool isDeviceCameraRefreshing = false;
  bool isStatisticsRefreshing = false;

  Future refresh() async {
    final devices = await DeviceApi.getDevices();
    if (devices.runtimeType == List<Device>) {
      di<DevicesModel>().devices = devices;
      logger.t('Fetched Devices by Refresh');
    }

    final weatherData = await WeatherApi.getWeatherData();
    if (weatherData.runtimeType == List<Weather>) {
      di<WeatherModel>().weather = weatherData;
      logger.t('Fetched Weather by Refresh');
    }

    final deviceCameraData = await DeviceApi.getDeviceCamera();
    if (deviceCameraData.runtimeType == List<DeviceCamera>) {
      di<DeviceCameraModel>().deviceCamera = deviceCameraData;
      logger.t('Fetched Device Camera by Refresh');
    }

    final weeklyCropCharts = await DeviceApi.getWeeklyCropChartData();
    if (weeklyCropCharts.runtimeType == CropChart) {
      di<CropChartModel>().weeklyCropCharts = weeklyCropCharts;
      logger.t('Fetched Weekly Crop Charts by Refresh');
    }

    final monthlyCropCharts = await DeviceApi.getMonthlyCropChartData();
    if (monthlyCropCharts.runtimeType == CropChart) {
      di<CropChartModel>().monthlyCropCharts = monthlyCropCharts;
      logger.t('Fetched Monthly Crop Charts by Refresh');
    }
  }

  @override
  void initState() {
    UserToken.getToken().then(
      (value) {
        token = value;
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final devices = watchPropertyValue((DevicesModel d) => d.devices.toList());
    final weather = watchPropertyValue((WeatherModel w) => w.weather.toList());
    final deviceCamera =
        watchPropertyValue((DeviceCameraModel dc) => dc.deviceCamera.toList());
    final cropCharts = watch(di<CropChartModel>());
    final weeklyCropCharts = cropCharts.weeklyCropCharts.data;
    final monthlyCropCharts = cropCharts.monthlyCropCharts.data;
    final homeListItems = watchPropertyValue((UserPrefs u) => u.homeListItems);

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
            token: token,
          ),
        )
        .toList();

    final cropLineChartsPages = [];
    if (weeklyCropCharts != null &&
        monthlyCropCharts != null &&
        weeklyCropCharts.isNotEmpty &&
        monthlyCropCharts.isNotEmpty) {
      for (var i = 0; i < weeklyCropCharts.length; i++) {
        cropLineChartsPages.add(
          CropLineChartCard(
            location: weeklyCropCharts[i].location!,
            cropName: weeklyCropCharts[i].cropName ?? 'Unassigned Crop',
            deviceName: weeklyCropCharts[i].deviceName!,
            weeklyMoisture: weeklyCropCharts[i].moisture!,
            weeklyNitrogen: weeklyCropCharts[i].nitrogen!,
            weeklyPh: weeklyCropCharts[i].ph!,
            weeklyPhosphorus: weeklyCropCharts[i].phosphorus!,
            weeklyPotassium: weeklyCropCharts[i].potassium!,
            weeklyTemperature: weeklyCropCharts[i].temperature!,
            weeklyCollectionDates: weeklyCropCharts[i].collectionDates!,
            monthlyMoisture: monthlyCropCharts[i].moisture!,
            monthlyNitrogen: monthlyCropCharts[i].nitrogen!,
            monthlyPh: monthlyCropCharts[i].ph!,
            monthlyPhosphorus: monthlyCropCharts[i].phosphorus!,
            monthlyPotassium: monthlyCropCharts[i].potassium!,
            monthlyTemperature: monthlyCropCharts[i].temperature!,
            monthlyCollectionDates: monthlyCropCharts[i].collectionDates!,
          ),
        );
      }
    }

    final Map<List<String>, List<Widget>> alerts = {};
    final Map<String, int> alertsCountForEachDevice = {};

    // add device alerts to alerts
    for (Device device in devices) {
      if (device.crop?.alerts == null) continue;

      alerts[[device.name!, device.location!, device.deviceId!]] = [
        // weather alerts
        buildWeatherAlerts(device, weather, alertsCountForEachDevice),

        // leaf alerts
        buildLeafAlerts(device, alertsCountForEachDevice),

        // soil alerts
        buildSoilAlerts(device, alertsCountForEachDevice),
      ];
    }

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
                        buildAlerts(alerts, alertsCountForEachDevice)
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
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weather',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 35,
                height: 35,
                child: IconButton(
                  icon: isWeatherRefreshing
                      ? const CircularProgressIndicator(
                          color: Colors.blue,
                        )
                      : const Icon(Icons.wb_cloudy_rounded),
                  color: Colors.blue,
                  onPressed: () {
                    if (isWeatherRefreshing) return;

                    setState(() {
                      isWeatherRefreshing = true;
                    });

                    WeatherApi.getWeatherData().then(
                      (weatherData) {
                        if (weatherData.runtimeType == List<Weather>) {
                          di<WeatherModel>().weather = weatherData;
                          logger.t('Fetched Weather by Refresh');
                        }

                        setState(() {
                          isWeatherRefreshing = false;
                        });
                      },
                    );
                  },
                ),
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
  Widget buildAlerts(Map<List<String>, List<Widget>> alerts,
      Map<String, int> alertsCountForEachDevice) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alerts',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 35,
                height: 35,
                child: IconButton(
                  icon: isAlertsRefreshing
                      ? const CircularProgressIndicator(
                          color: Colors.red,
                        )
                      : const Icon(Icons.notifications_rounded),
                  color: Colors.red,
                  onPressed: () {
                    if (isAlertsRefreshing) return;

                    setState(() {
                      isAlertsRefreshing = true;
                    });

                    WeatherApi.getWeatherData().then(
                      (weatherData) {
                        if (weatherData.runtimeType == List<Weather>) {
                          di<WeatherModel>().weather = weatherData;
                          logger.t('Fetched Weather by Refresh');
                        }

                        DeviceApi.getDevices().then(
                          (devices) {
                            if (devices.runtimeType == List<Device>) {
                              di<DevicesModel>().devices = devices;
                              logger.t('Fetched Devices by Refresh');
                            }
                          },
                        );

                        setState(() {
                          isAlertsRefreshing = false;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // for (var alert in weatherAlerts)
          //   ExpansionTileCard(
          //     title: Text(
          //         '${alert!['device']} (${(alert['alert'] as List<dynamic>).length} ${(alert['alert'] as List<dynamic>).length == 1 ? 'Alert' : 'Alerts'})'),
          //     subtitle: Text(alert['location'].toString()),
          //     children: [
          //       for (var a in alert['alert'] as List<dynamic>)
          //         ListTile(
          //           title: Text(
          //             a,
          //             style: const TextStyle(color: Colors.red),
          //           ),
          //         ),
          //     ],
          //   ),
          for (var alert in alerts.entries)
            ExpansionTileCard(
              title: Text(
                  '${alert.key[0]} (${alertsCountForEachDevice[alert.key[2]]} ${alertsCountForEachDevice[alert.key[2]] == 1 ? 'Alert' : 'Alerts'})'),
              subtitle: Text(alert.key[1]),
              children: alert.value,
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
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Device Camera',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 35,
                height: 35,
                child: IconButton(
                  icon: isDeviceCameraRefreshing
                      ? const CircularProgressIndicator(
                          color: Colors.green,
                        )
                      : const Icon(Icons.camera_alt_rounded),
                  color: Colors.green,
                  onPressed: () {
                    if (isDeviceCameraRefreshing) return;

                    setState(() {
                      isDeviceCameraRefreshing = true;
                    });

                    DeviceApi.getDeviceCamera().then(
                      (deviceCameraData) {
                        if (deviceCameraData.runtimeType ==
                            List<DeviceCamera>) {
                          di<DeviceCameraModel>().deviceCamera =
                              deviceCameraData;
                          logger.t('Fetched Device Camera by Refresh');
                        }

                        setState(() {
                          isDeviceCameraRefreshing = false;
                        });
                      },
                    );
                  },
                ),
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
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Statistics',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 35,
                height: 35,
                child: IconButton(
                  icon: isStatisticsRefreshing
                      ? const CircularProgressIndicator(
                          color: Colors.orange,
                        )
                      : const Icon(Icons.bar_chart_rounded),
                  color: Colors.orange,
                  onPressed: () {
                    if (isStatisticsRefreshing) return;

                    setState(() {
                      isStatisticsRefreshing = true;
                    });

                    DeviceApi.getWeeklyCropChartData().then(
                      (weeklyCropCharts) {
                        if (weeklyCropCharts.runtimeType == CropChart) {
                          di<CropChartModel>().weeklyCropCharts =
                              weeklyCropCharts;
                          logger.t('Fetched Weekly Crop Charts by Refresh');
                        }

                        DeviceApi.getMonthlyCropChartData().then(
                          (monthlyCropCharts) {
                            if (monthlyCropCharts.runtimeType == CropChart) {
                              di<CropChartModel>().monthlyCropCharts =
                                  monthlyCropCharts;
                              logger
                                  .t('Fetched Monthly Crop Charts by Refresh');
                            }

                            setState(() {
                              isStatisticsRefreshing = false;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const Gap(16),
        SizedBox(
          width: double.infinity,
          height: 501,
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

  // Function to handle leaf alerts
  Widget buildLeafAlerts(
      Device device, Map<String, int> alertsCountForEachDevice) {
    if (device.crop?.alerts?.leaf == null ||
        device.crop?.alerts?.leaf?.status == null) {
      return const SizedBox.shrink(); // No leaf alerts, return an empty widget
    }

    // if leaf is healthy, return empty widget
    if (device.crop?.alerts?.leaf?.status?.toLowerCase() == 'healthy') {
      return const SizedBox.shrink();
    }

    // increment the alert count for each device
    if (alertsCountForEachDevice[device.deviceId!] == null) {
      alertsCountForEachDevice[device.deviceId!] = 1;
    } else {
      alertsCountForEachDevice[device.deviceId!] =
          alertsCountForEachDevice[device.deviceId!]! + 1;
    }

    return ListTile(
      title: Row(
        children: [
          const Text('Leaf Condition: '),
          Text(
            '${device.crop?.alerts?.leaf?.status}',
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ],
      ),
      subtitle: device.crop?.alerts?.leaf?.message == [] ||
              device.crop?.alerts?.leaf?.action == []
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // messages
                if (device.crop?.alerts?.leaf?.message != null)
                  for (String message in device.crop!.alerts!.leaf!.message!)
                    Text(
                        'Message${device.crop!.alerts!.leaf!.message!.indexOf(message) + 1 == 1 ? '' : device.crop!.alerts!.leaf!.message!.indexOf(message) + 1}: $message'),

                // actions
                if (device.crop?.alerts?.leaf?.action != null)
                  for (String action in device.crop!.alerts!.leaf!.action!)
                    Text('Action Required: $action'),
              ],
            )
          : null,
    );
  }

  // Function to handle soil alerts
  Widget buildSoilAlerts(
      Device device, Map<String, int> alertsCountForEachDevice) {
    if (device.crop?.alerts?.soil == null ||
        device.crop?.alerts?.soil?.message == null) {
      return const SizedBox.shrink(); // No soil alerts, return an empty widget
    }

    final widget = ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < device.crop!.alerts!.soil!.message!.length; i++)
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    height: 30,
                    child: Image.asset(
                      'assets/icon/${device.crop!.alerts!.soil!.nutrient![i].toLowerCase() == 'ph' ? 'ph' : device.crop!.alerts!.soil!.nutrient![i].toLowerCase() == 'humidity' || device.crop!.alerts!.soil!.nutrient![i].toLowerCase() == 'moisture' ? 'moisture' : device.crop!.alerts!.soil!.nutrient![i].toLowerCase() == 'nitrogen' ? 'nitrogen' : device.crop!.alerts!.soil!.nutrient![i].toLowerCase() == 'phosphorus' || device.crop!.alerts!.soil!.nutrient![i].toLowerCase() == 'phosphorous' ? 'phosphorus' : device.crop!.alerts!.soil!.nutrient![i].toLowerCase() == 'potassium' ? 'potassium' : device.crop!.alerts!.soil!.nutrient![i].toLowerCase() == 'temperature' ? 'temperature' : 'warning'}.png',
                      color: MyApp.themeNotifier.value == ThemeMode.light
                          ? const Color(0xFF3F4642)
                          : const Color(0xFFBEC6BF),
                    ),
                  ),
                  title: Text(
                    device.crop!.alerts!.soil!.message![i],
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Severity: ${device.crop!.alerts!.soil!.severity![i][0].toUpperCase() + device.crop!.alerts!.soil!.severity![i].substring(1)}',
                          style: TextStyle(
                            color: device.crop!.alerts!.soil!.severity![i]
                                        .toLowerCase() ==
                                    'high'
                                ? Colors.red
                                : Colors.orange,
                          )),
                      Text(
                        'Action Required: ${device.crop!.alerts!.soil!.action![i]}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );

    // increment the alert count for each device based on how many soil alerts there are
    if (alertsCountForEachDevice[device.deviceId!] == null) {
      alertsCountForEachDevice[device.deviceId!] =
          device.crop!.alerts!.soil!.message!.length;
    } else {
      alertsCountForEachDevice[device.deviceId!] =
          alertsCountForEachDevice[device.deviceId]! +
              device.crop!.alerts!.soil!.message!.length;
    }

    return widget;
  }

  Widget buildWeatherAlerts(Device device, List<Weather> weather,
      Map<String, int> alertsCountForEachDevice) {
    if (weather.isEmpty) return const SizedBox.shrink();

    final weatherAlerts = weather
        .where((element) => element.deviceId == device.deviceId)
        .toList();

    if (weatherAlerts.isEmpty ||
        weatherAlerts[0].airQuality == null ||
        weatherAlerts.first.airQuality!['us-epa-index']! < 4) {
      return const SizedBox.shrink();
    }

    final widget = ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (Weather w in weatherAlerts)
            if (w.airQuality != null &&
                w.airQuality!.isNotEmpty &&
                w.airQuality!['us-epa-index']! > 4)
              Text(
                'Air Quality: ${w.airQuality!['us-epa-index']! == 4 ? 'Unhealthy' : w.airQuality!['us-epa-index']! == 5 ? 'Very Unhealthy' : 'Hazardous'}',
              ),
        ],
      ),
    );

    // increment the alert count for each device based on how many weather alerts there are
    if (alertsCountForEachDevice[device.deviceId!] == null) {
      alertsCountForEachDevice[device.deviceId!] = weatherAlerts.length;
    } else {
      alertsCountForEachDevice[device.deviceId!] =
          alertsCountForEachDevice[device.deviceId]! + weatherAlerts.length;
    }

    return widget;
  }
}
