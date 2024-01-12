import 'package:cropsync/json/weather.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

Widget overviewCard(Weather weather) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.phone_android_rounded),
              const Gap(8),
              Text(weather.deviceName!),
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
              const Icon(Icons.wb_sunny),
              const Gap(8),
              Text(weather.temperature!.toString()),
            ],
          ),
          const Gap(16),
           Row(
            children: [
              const Icon(Icons.opacity),
              const Gap(8),
              Text(weather.humidity!.toString()),
            ],
          ),
          const Gap(16),
           Row(
            children: [
              const Icon(Icons.waves),
              const Gap(8),
              Text(weather.moisture!.toString()),
            ],
          ),
        ],
      ),
    ),
  );
}