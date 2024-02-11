import 'package:cropsync/json/weather.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

Widget overviewCard({required Weather weather, required BuildContext context}) {
  return InkWell(
    onTap: () {
      Navigator.pushNamed(context, '/weather-forecast', arguments: {
        'deviceId': weather.deviceId,
      });
    },
    borderRadius: BorderRadius.circular(16),
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.phone_android_rounded),
                const Gap(8),
                Text(weather.name!),
              ],
            ),
            const Gap(16),
            Row(
              children: [
                const Icon(Icons.location_on_rounded),
                const Gap(8),
                Text(weather.location!),
              ],
            ),
            const Gap(16),
            Row(
              children: [
                const Icon(Icons.thermostat_rounded),
                const Gap(8),
                Text("Temperature: ${weather.tempC} °C"),
              ],
            ),
            const Gap(16),
            Row(
              children: [
                const Icon(Icons.cloud_rounded),
                const Gap(8),
                Text("Feels Like ${weather.feelslikeC} °C"),
              ],
            ),
            const Gap(16),
            Row(
              children: [
                const Icon(Icons.wb_cloudy_rounded),
                const Gap(8),
                Text("Condition ${weather.condition?.text}"),
              ],
            ),
            const Gap(16),
            Row(
              children: [
                const Icon(Icons.opacity_rounded),
                const Gap(8),
                Text("Humidity: ${weather.humidity}"),
              ],
            ),
            // const Gap(16),
            //  Row(
            //   children: [
            //     const Icon(Icons.waves),
            //     const Gap(8),
            //     Text("Moisture: ${weather.moisture!}"),
            //   ],
            // ),
          ],
        ),
      ),
    ),
  );
}
