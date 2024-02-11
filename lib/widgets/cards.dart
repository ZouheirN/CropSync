import 'package:cached_network_image/cached_network_image.dart';
import 'package:cropsync/json/weather.dart';
import 'package:cropsync/json/weather_forecast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';

Widget weatherCard({
  required Weather weather,
  bool isTappable = false,
  required BuildContext context,
}) {
  return InkWell(
    onTap: isTappable
        ? () {
            Navigator.pushNamed(context, '/weather-forecast', arguments: {
              'deviceId': weather.deviceId,
              'deviceName': weather.name,
              'deviceLocation': weather.location,
            });
          }
        : null,
    borderRadius: BorderRadius.circular(16),
    child: Card(
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
                const FaIcon(FontAwesomeIcons.raspberryPi),
                const Gap(8),
                Text(
                  weather.name!,
                  style: Theme.of(context).textTheme.titleMedium!,
                ),
              ],
            ),
            const Gap(2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(FontAwesomeIcons.locationDot),
                    const Gap(8),
                    Text(
                      weather.location!,
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(FontAwesomeIcons.calendar),
                    const Gap(8),
                    Text(
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                    Text(
                      weather.condition!.text!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${formatFloat(weather.tempC!)}°',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 70,
                                  ),
                        ),
                        Text(
                          'Feels like ${formatFloat(weather.feelslikeC!)}°',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
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
                      const FaIcon(
                        FontAwesomeIcons.wind,
                        // size: 20,
                      ),
                      const Gap(2),
                      Text('${formatFloat(weather.windKph!)} km/h'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.droplet,
                        // size: 20,
                      ),
                      const Gap(2),
                      Text('${formatFloat(weather.humidity!)}%'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.cloudShowersHeavy,
                        // size: 20,
                      ),
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

Widget weatherForecastCard({
  required WeatherDatum weather,
  required BuildContext context,
}) {
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
              const FaIcon(FontAwesomeIcons.calendar),
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
              Column(
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
                  Text(
                    weather.condition!.text!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    children: [
                      Text(
                        '${formatFloat(weather.avgtempC!)}°',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                    const FaIcon(
                      FontAwesomeIcons.wind,
                      // size: 20,
                    ),
                    const Gap(2),
                    Text('${formatFloat(weather.maxwindKph!)} km/h'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.droplet,
                      // size: 20,
                    ),
                    const Gap(2),
                    Text('${formatFloat(weather.avghumidity!)}%'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.cloudShowersHeavy,
                      // size: 20,
                    ),
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
