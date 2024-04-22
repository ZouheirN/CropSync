import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cropsync/json/device_camera.dart';
import 'package:cropsync/json/weather.dart';
import 'package:cropsync/json/weather_forecast.dart';
import 'package:cropsync/main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:icons_plus/icons_plus.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;
  final bool isTappable;
  final BuildContext context;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.context,
    this.isTappable = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isTappable
          ? () {
              Navigator.pushNamed(
                context,
                '/weather-forecast',
                arguments: {
                  'deviceId': weather.deviceId,
                  'deviceName': weather.name,
                  'deviceLocation': weather.location,
                },
              );
            }
          : null,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        // margin: const EdgeInsets.all(0),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const FaIcon(FontAwesomeIcons.raspberryPi),
                  const Icon(FontAwesome.raspberry_pi_brand),
                  const Gap(8),
                  Flexible(
                    child: AutoSizeText(
                      textAlign: TextAlign.center,
                      weather.name!,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                  ),
                ],
              ),
              const Gap(2),
              Row(
                children: [
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(FontAwesome.location_dot_solid),
                        const Gap(8),
                        Flexible(
                          child: AutoSizeText(
                            textAlign: TextAlign.left,
                            weather.location!,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.titleMedium!,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(FontAwesome.calendar),
                        const Gap(8),
                        Flexible(
                          child: AutoSizeText(
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                            style: Theme.of(context).textTheme.titleMedium!,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: 'https:${weather.condition!.icon!}',
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                            value: downloadProgress.progress,
                          ),
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              width: 100.0,
                              height: 100.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                        Flexible(
                          child: AutoSizeText(
                            weather.condition!.text!,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxFontSize: 16,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${formatFloat(weather.tempC!)}°',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 70,
                                ),
                          ),
                          Text(
                            'Feels like ${formatFloat(weather.feelslikeC!)}°',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 18,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(FontAwesome.wind_solid),
                        const Gap(2),
                        Text('${formatFloat(weather.windKph!)} km/h'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(FontAwesome.droplet_solid),
                        const Gap(2),
                        Text('${formatFloat(weather.humidity!)}%'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(FontAwesome.cloud_showers_heavy_solid),
                        const Gap(2),
                        Text("${formatFloat(weather.cloud!)}%"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherForecastCard extends StatelessWidget {
  final WeatherDatum weather;
  final BuildContext context;

  const WeatherForecastCard({
    super.key,
    required this.weather,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(FontAwesome.calendar),
                const Gap(8),
                Text(
                  convertDateFormat(weather.date.toString().substring(0, 10)),
                  style: Theme.of(context).textTheme.titleMedium!,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl: 'https:${weather.condition!.icon!}',
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                          value: downloadProgress.progress,
                        ),
                        imageBuilder: (context, imageProvider) {
                          return Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                      Flexible(
                        child: AutoSizeText(
                          weather.condition!.text!,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxFontSize: 16,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      children: [
                        Text(
                          '${formatFloat(weather.avgtempC!)}°',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 70,
                                  ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(FontAwesome.wind_solid),
                      const Gap(2),
                      Text('${formatFloat(weather.maxwindKph!)} km/h'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(FontAwesome.droplet_solid),
                      const Gap(2),
                      Text('${formatFloat(weather.avghumidity!)}%'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(FontAwesome.cloud_showers_heavy_solid),
                      const Gap(2),
                      Text('${formatFloat(weather.dailyChanceOfRain!)}%'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceCameraCard extends StatelessWidget {
  final DeviceCamera deviceCamera;
  final BuildContext context;
  final String token;

  const DeviceCameraCard({
    super.key,
    required this.deviceCamera,
    required this.context,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/device-camera-history', arguments: {
          'deviceCamera': deviceCamera,
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  if (deviceCamera.recentLeafImage == null)
                    SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Center(
                        child: Text(
                          'No Image Available',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    )
                  else
                    CachedNetworkImage(
                      imageUrl: deviceCamera.recentLeafImage!,
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                      errorWidget: (context, url, error) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_rounded,
                              color: Colors.red,
                            ),
                            Text('Error Getting Image',
                                style: TextStyle(color: Colors.red))
                          ],
                        );
                      },
                      progressIndicatorBuilder: (context, url, progress) =>
                          Center(
                        child: CircularProgressIndicator(
                          value: progress.progress,
                        ),
                      ),
                      httpHeaders: {
                        "Authorization": "Bearer $token",
                      },
                    ),
                  if (deviceCamera.cameraCollectionDate != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        width: double.infinity,
                        color: Colors.black54,
                        child: Text(
                          'Snapshot Time: ${convertDateFormat(deviceCamera.cameraCollectionDate.toString(), withTime: true)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    FontAwesome.raspberry_pi_brand,
                    size: 20,
                    color: MyApp.themeNotifier.value == ThemeMode.light
                        ? Colors.black
                        : Colors.white,
                  ),
                  const Gap(8),
                  Flexible(
                    child: AutoSizeText(
                      textAlign: TextAlign.left,
                      deviceCamera.name!,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium!,
                      minFontSize: 10,
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    FontAwesome.location_dot_solid,
                    size: 20,
                    color: MyApp.themeNotifier.value == ThemeMode.light
                        ? Colors.black
                        : Colors.white,
                  ),
                  const Gap(8),
                  Flexible(
                    child: AutoSizeText(
                      textAlign: TextAlign.left,
                      deviceCamera.location!,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium!,
                      minFontSize: 10,
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.grass_rounded,
                    size: 20,
                    color: deviceCamera.cropName == null
                        ? Colors.red
                        : MyApp.themeNotifier.value == ThemeMode.light
                            ? Colors.black
                            : Colors.white,
                  ),
                  Flexible(
                    child: AutoSizeText(
                      textAlign: TextAlign.center,
                      deviceCamera.cropName ?? 'Unassigned Crop',
                      maxLines: 2,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: deviceCamera.cropName == null
                                ? Colors.red
                                : null,
                          ),
                      minFontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String convertDateFormat(String dateString, {bool withTime = false}) {
  // Parse the input date string
  DateTime dateTime = DateTime.parse(dateString);

  // Extract day, month, and year
  int day = dateTime.day;
  int month = dateTime.month;
  int year = dateTime.year;

  // Format the date in the desired format
  String formattedDate = '$day/$month/$year';

  // Include time if withTime is true
  if (withTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    formattedDate +=
        ' - ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  return formattedDate;
}

String formatFloat(double number) {
  // Check if the number is an integer
  if (number % 1 == 0) {
    return number.toInt().toString(); // Return integer part as string
  } else {
    String formatted =
        number.toStringAsFixed(2); // Return number with 2 decimal places
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r"([.]*0)(?!.*\d)"),
          ""); // Remove trailing zeros after decimal point
    }
    return formatted;
  }
}

class CropLineChartCard extends StatefulWidget {
  final String deviceName;
  final String cropName;
  final String location;
  final List<double> weeklyNitrogen;
  final List<double> weeklyPhosphorus;
  final List<double> weeklyPotassium;
  final List<double> weeklyTemperature;
  final List<double> weeklyPh;
  final List<double> weeklyMoisture;
  final List<DateTime> weeklyCollectionDates;
  final List<double> monthlyNitrogen;
  final List<double> monthlyPhosphorus;
  final List<double> monthlyPotassium;
  final List<double> monthlyTemperature;
  final List<double> monthlyPh;
  final List<double> monthlyMoisture;
  final List<DateTime> monthlyCollectionDates;

  const CropLineChartCard({
    super.key,
    required this.deviceName,
    required this.cropName,
    required this.location,
    required this.weeklyNitrogen,
    required this.weeklyPhosphorus,
    required this.weeklyPotassium,
    required this.weeklyTemperature,
    required this.weeklyPh,
    required this.weeklyMoisture,
    required this.monthlyNitrogen,
    required this.monthlyPhosphorus,
    required this.monthlyPotassium,
    required this.monthlyTemperature,
    required this.monthlyPh,
    required this.monthlyMoisture,
    required this.weeklyCollectionDates,
    required this.monthlyCollectionDates,
  });

  @override
  State<CropLineChartCard> createState() => _CropLineChartCardState();
}

class _CropLineChartCardState extends State<CropLineChartCard> {
  bool showNitrogen = true;
  bool showPhosphorus = true;
  bool showPotassium = true;
  bool showTemperature = true;
  bool showPh = true;
  bool showMoisture = true;

  Set<String> selected = {
    'nitrogen',
    'phosphorus',
    'potassium',
    'temperature',
    'ph',
    'moisture'
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(FontAwesome.raspberry_pi_brand),
                const Gap(8),
                Flexible(
                  child: AutoSizeText(
                    textAlign: TextAlign.center,
                    widget.deviceName,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleMedium!,
                  ),
                ),
              ],
            ),
            const Gap(2),
            Row(
              children: [
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(FontAwesome.location_dot_solid),
                      const Gap(8),
                      Flexible(
                        child: AutoSizeText(
                          textAlign: TextAlign.left,
                          widget.location,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.titleMedium!,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.grass_rounded,
                          color: widget.cropName == "Unassigned Crop"
                              ? Colors.red
                              : null),
                      const Gap(8),
                      Flexible(
                        child: AutoSizeText(
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          widget.cropName,
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: widget.cropName == 'Unassigned Crop'
                                        ? Colors.red
                                        : null,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(2),
            Text(
              'Recent Soil Readings',
              style: Theme.of(context).textTheme.titleLarge!,
            ),
            SizedBox(
              height: 340,
              child: DefaultTabController(
                length: 2,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    toolbarHeight: 50,
                    title: const TabBar(
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(text: 'Weekly'),
                        Tab(text: 'Monthly'),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      if (widget.weeklyMoisture.isEmpty)
                        Center(
                          child: Text(
                            'No Data Available',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        )
                      else
                        buildLineChart(
                          moisture: widget.weeklyMoisture,
                          nitrogen: widget.weeklyNitrogen,
                          ph: widget.weeklyPh,
                          phosphorus: widget.weeklyPhosphorus,
                          potassium: widget.weeklyPotassium,
                          temperature: widget.weeklyTemperature,
                          collectionDates: widget.weeklyCollectionDates,
                        ),
                      if (widget.monthlyMoisture.isEmpty)
                        Center(
                          child: Text(
                            'No Data Available',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        )
                      else
                        buildLineChart(
                          moisture: widget.monthlyMoisture,
                          nitrogen: widget.monthlyNitrogen,
                          ph: widget.monthlyPh,
                          phosphorus: widget.monthlyPhosphorus,
                          potassium: widget.monthlyPotassium,
                          temperature: widget.monthlyTemperature,
                          collectionDates: widget.monthlyCollectionDates,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(2),
            SegmentedButton(
              multiSelectionEnabled: true,
              selected: selected,
              showSelectedIcon: false,
              emptySelectionAllowed: false,
              onSelectionChanged: (selected) {
                setState(() {
                  this.selected = selected;
                  showNitrogen = selected.contains('nitrogen');
                  showPhosphorus = selected.contains('phosphorus');
                  showPotassium = selected.contains('potassium');
                  showTemperature = selected.contains('temperature');
                  showPh = selected.contains('ph');
                  showMoisture = selected.contains('moisture');
                });
              },
              segments: <ButtonSegment<String>>[
                ButtonSegment<String>(
                  value: 'nitrogen',
                  tooltip: 'Nitrogen',
                  icon: Image.asset(
                    'assets/icon/nitrogen.png',
                    color: Colors.blue,
                  ),
                ),
                ButtonSegment<String>(
                  value: 'phosphorus',
                  tooltip: 'Phosphorus',
                  icon: Image.asset(
                    'assets/icon/phosphorus.png',
                    color: Colors.red,
                  ),
                ),
                ButtonSegment<String>(
                  value: 'potassium',
                  tooltip: 'Potassium',
                  icon: Image.asset(
                    'assets/icon/potassium.png',
                    color: Colors.green,
                  ),
                ),
                ButtonSegment<String>(
                  value: 'temperature',
                  tooltip: 'Temperature',
                  icon: Image.asset(
                    'assets/icon/temperature.png',
                    color: Colors.orange,
                  ),
                ),
                ButtonSegment<String>(
                  value: 'ph',
                  tooltip: 'pH',
                  icon: Image.asset(
                    'assets/icon/ph.png',
                    color: Colors.purple,
                  ),
                ),
                ButtonSegment<String>(
                  value: 'moisture',
                  tooltip: 'Moisture',
                  icon: Image.asset(
                    'assets/icon/moisture.png',
                    color: Colors.brown,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  LineChart buildLineChart({
    nitrogen,
    phosphorus,
    potassium,
    temperature,
    ph,
    moisture,
    collectionDates,
  }) {
    return LineChart(
      LineChartData(
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
                color: MyApp.themeNotifier.value == ThemeMode.light
                    ? Colors.black
                    : Colors.white,
                width: 2),
            // bottom: BorderSide(color: Colors.transparent),
            left: BorderSide(
                color: MyApp.themeNotifier.value == ThemeMode.light
                    ? Colors.black
                    : Colors.white,
                width: 2),
            right: const BorderSide(color: Colors.transparent),
            top: const BorderSide(color: Colors.transparent),
          ),
        ),
        minY: getMinimumValue(
            nitrogen, phosphorus, potassium, temperature, ph, moisture),
        maxY: getMaximumValue(
            nitrogen, phosphorus, potassium, temperature, ph, moisture),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(axisNameWidget: Text('')),
          topTitles: const AxisTitles(axisNameWidget: Text('')),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (value, meta) {
                if (selected.length == 1) {
                  return Text(
                    value.toStringAsFixed(2),
                    style: TextStyle(
                      color: MyApp.themeNotifier.value == ThemeMode.light
                          ? Colors.black
                          : Colors.white,
                      fontSize: 12,
                    ),
                  );
                }

                if (value == meta.max && value == meta.min) {
                  return Text(
                    value.toStringAsFixed(2),
                    style: TextStyle(
                      color: MyApp.themeNotifier.value == ThemeMode.light
                          ? Colors.black
                          : Colors.white,
                      fontSize: 12,
                    ),
                  );
                }

                if (value == meta.max || value == meta.min) {
                  return const Text('');
                }

                return Text(
                  value.toStringAsFixed(2),
                  style: TextStyle(
                    color: MyApp.themeNotifier.value == ThemeMode.light
                        ? Colors.black
                        : Colors.white,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (value, meta) {
                // if (value == meta.max) {
                //   return const Text('');
                // }

                DateTime dateTime = collectionDates[value.toInt()];
                String month = dateTime.month.toString();
                String day = dateTime.day.toString();

                return RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    ' $day/$month',
                    style: TextStyle(
                      color: MyApp.themeNotifier.value == ThemeMode.light
                          ? Colors.black
                          : Colors.white,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: const LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideVertically: true,
          ),
        ),
        gridData: const FlGridData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < nitrogen.length; i++)
                FlSpot(i.toDouble(), nitrogen[i].toDouble())
            ],
            isCurved: true,
            color: Colors.blue,
            show: showNitrogen,
            preventCurveOverShooting: true,
          ),
          LineChartBarData(
            spots: [
              for (var i = 0; i < phosphorus.length; i++)
                FlSpot(i.toDouble(), phosphorus[i].toDouble())
            ],
            isCurved: true,
            color: Colors.red,
            show: showPhosphorus,
            preventCurveOverShooting: true,
          ),
          LineChartBarData(
            spots: [
              for (var i = 0; i < potassium.length; i++)
                FlSpot(i.toDouble(), potassium[i].toDouble())
            ],
            isCurved: true,
            color: Colors.green,
            show: showPotassium,
            preventCurveOverShooting: true,
          ),
          LineChartBarData(
            spots: [
              for (var i = 0; i < temperature.length; i++)
                FlSpot(i.toDouble(), temperature[i].toDouble())
            ],
            isCurved: true,
            color: Colors.orange,
            show: showTemperature,
            preventCurveOverShooting: true,
          ),
          LineChartBarData(
            spots: [
              for (var i = 0; i < ph.length; i++)
                FlSpot(i.toDouble(), ph[i].toDouble())
            ],
            isCurved: true,
            color: Colors.purple,
            show: showPh,
            preventCurveOverShooting: true,
          ),
          LineChartBarData(
            spots: [
              for (var i = 0; i < moisture.length; i++)
                FlSpot(i.toDouble(), moisture[i].toDouble())
            ],
            isCurved: true,
            color: Colors.brown,
            show: showMoisture,
            preventCurveOverShooting: true,
          ),
        ],
      ),
    );
  }

  getMinimumValue(
      List<double> nitrogen,
      List<double> phosphorus,
      List<double> potassium,
      List<double> temperature,
      List<double> ph,
      List<double> moisture) {
    List<double> values = [
      if (showNitrogen) ...nitrogen,
      if (showPhosphorus) ...phosphorus,
      if (showPotassium) ...potassium,
      if (showTemperature) ...temperature,
      if (showPh) ...ph,
      if (showMoisture) ...moisture,
    ];

    List<double> forcedValues = [
      ...nitrogen,
      ...phosphorus,
      ...potassium,
      ...temperature,
      ...ph,
      ...moisture,
    ];

    if (values.isEmpty) {
      return forcedValues
          .reduce((value, element) => value < element ? value : element);
    }

    return values.reduce((value, element) => value < element ? value : element);
  }

  double getMaximumValue(
      List<double> nitrogen,
      List<double> phosphorus,
      List<double> potassium,
      List<double> temperature,
      List<double> ph,
      List<double> moisture) {
    List<double> values = [
      if (showNitrogen) ...nitrogen,
      if (showPhosphorus) ...phosphorus,
      if (showPotassium) ...potassium,
      if (showTemperature) ...temperature,
      if (showPh) ...ph,
      if (showMoisture) ...moisture,
    ];

    List<double> forcedValues = [
      ...nitrogen,
      ...phosphorus,
      ...potassium,
      ...temperature,
      ...ph,
      ...moisture,
    ];

    if (values.isEmpty) {
      return forcedValues
          .reduce((value, element) => value > element ? value : element);
    }

    return values.reduce((value, element) => value > element ? value : element);
  }
}
