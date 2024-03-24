import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cropsync/json/device_camera.dart';
import 'package:cropsync/json/weather.dart';
import 'package:cropsync/json/weather_forecast.dart';
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

  const DeviceCameraCard({
    super.key,
    required this.deviceCamera,
    required this.context,
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
              child: Image.memory(
                base64Decode(deviceCamera.image!),
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    FontAwesome.raspberry_pi_brand,
                    size: 20,
                  ),
                  const Gap(8),
                  Flexible(
                    child: AutoSizeText(
                      textAlign: TextAlign.center,
                      deviceCamera.deviceName!,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    FontAwesome.location_dot_solid,
                    size: 20,
                  ),
                  const Gap(8),
                  Flexible(
                    child: AutoSizeText(
                      textAlign: TextAlign.center,
                      deviceCamera.location!,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.grass_rounded,
                    size: 20,
                  ),
                  Flexible(
                    child: AutoSizeText(
                      textAlign: TextAlign.center,
                      deviceCamera.cropName!,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleSmall!,
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
    formattedDate += ' - ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
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
  final List<double> nitrogen;
  final List<double> phosphorus;
  final List<double> potassium;
  final List<double> temperature;
  final List<double> ph;
  final List<double> moisture;

  const CropLineChartCard({
    super.key,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.temperature,
    required this.ph,
    required this.moisture,
    required this.deviceName,
    required this.cropName,
    required this.location,
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
                      const Icon(Icons.grass_rounded),
                      const Gap(8),
                      Flexible(
                        child: AutoSizeText(
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          widget.cropName,
                          style: Theme.of(context).textTheme.titleMedium!,
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
              style: Theme.of(context).textTheme.titleMedium!,
            ),
            SizedBox(
              height: 270,
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      // bottom: BorderSide(color: Colors.white, width: 2),
                      bottom: BorderSide(color: Colors.transparent),
                      left: BorderSide(color: Colors.white, width: 2),
                      right: BorderSide(color: Colors.transparent),
                      top: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  minY: getMinimumValue(
                      widget.nitrogen,
                      widget.phosphorus,
                      widget.potassium,
                      widget.temperature,
                      widget.ph,
                      widget.moisture),
                  maxY: getMaximumValue(
                      widget.nitrogen,
                      widget.phosphorus,
                      widget.potassium,
                      widget.temperature,
                      widget.ph,
                      widget.moisture),
                  titlesData: const FlTitlesData(
                      rightTitles: AxisTitles(axisNameWidget: Text('')),
                      topTitles: AxisTitles(axisNameWidget: Text('')),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: false,
                      ))
                      // bottomTitles: AxisTitles(
                      //     sideTitles: SideTitles(
                      //   showTitles: true,
                      //   reservedSize: 24,
                      //   getTitlesWidget: (value, titleMeta) {
                      //     final day = DateTime.now()
                      //         .subtract(Duration(days: (6 - value).toInt()))
                      //         .day;
                      //     return SideTitleWidget(
                      //       axisSide: AxisSide.bottom,
                      //       child: Text(day.toString()),
                      //     );
                      //   },
                      // )),
                      // rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      // topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                  gridData: const FlGridData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < widget.nitrogen.length; i++)
                          FlSpot(i.toDouble(), widget.nitrogen[i].toDouble())
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      show: showNitrogen,
                      preventCurveOverShooting: true,
                    ),
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < widget.phosphorus.length; i++)
                          FlSpot(i.toDouble(), widget.phosphorus[i].toDouble())
                      ],
                      isCurved: true,
                      color: Colors.red,
                      show: showPhosphorus,
                      preventCurveOverShooting: true,
                    ),
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < widget.potassium.length; i++)
                          FlSpot(i.toDouble(), widget.potassium[i].toDouble())
                      ],
                      isCurved: true,
                      color: Colors.green,
                      show: showPotassium,
                      preventCurveOverShooting: true,
                    ),
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < widget.temperature.length; i++)
                          FlSpot(i.toDouble(), widget.temperature[i].toDouble())
                      ],
                      isCurved: true,
                      color: Colors.orange,
                      show: showTemperature,
                      preventCurveOverShooting: true,
                    ),
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < widget.ph.length; i++)
                          FlSpot(i.toDouble(), widget.ph[i].toDouble())
                      ],
                      isCurved: true,
                      color: Colors.purple,
                      show: showPh,
                      preventCurveOverShooting: true,
                    ),
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < widget.moisture.length; i++)
                          FlSpot(i.toDouble(), widget.moisture[i].toDouble())
                      ],
                      isCurved: true,
                      color: Colors.brown,
                      show: showMoisture,
                      preventCurveOverShooting: true,
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: showNitrogen,
                      onChanged: (value) {
                        setState(() {
                          showNitrogen = value!;
                        });
                      },
                    ),
                    const Text(
                      'Nitrogen',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: showPhosphorus,
                      onChanged: (value) {
                        setState(() {
                          showPhosphorus = value!;
                        });
                      },
                    ),
                    const Text(
                      'Phosphorus',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: showPotassium,
                      onChanged: (value) {
                        setState(() {
                          showPotassium = value!;
                        });
                      },
                    ),
                    const Text(
                      'Potassium',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: showTemperature,
                      onChanged: (value) {
                        setState(() {
                          showTemperature = value!;
                        });
                      },
                    ),
                    const Text(
                      'Temperature',
                      style: TextStyle(
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: showPh,
                      onChanged: (value) {
                        setState(() {
                          showPh = value!;
                        });
                      },
                    ),
                    const Text(
                      'pH',
                      style: TextStyle(
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: showMoisture,
                      onChanged: (value) {
                        setState(() {
                          showMoisture = value!;
                        });
                      },
                    ),
                    const Text(
                      'Moisture',
                      style: TextStyle(
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
