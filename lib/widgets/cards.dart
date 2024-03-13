import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cropsync/json/device_camera.dart';
import 'package:cropsync/json/weather.dart';
import 'package:cropsync/json/weather_forecast.dart';
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
              title: Text(
                deviceCamera.deviceName!,
              ),
              subtitle: Text(
                deviceCamera.location!,
              ),
              trailing: Text(
                deviceCamera.cropName!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String convertDateFormat(String dateString) {
  // Parse the input date string
  DateTime dateTime = DateTime.parse(dateString);

  // Extract day, month, and year
  int day = dateTime.day;
  int month = dateTime.month;
  int year = dateTime.year;

  // Format the date in the desired format
  String formattedDate = '$day/$month/$year';

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
