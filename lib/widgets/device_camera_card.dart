import 'dart:convert';

import 'package:cropsync/json/device_camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

Widget deviceCameraCard(DeviceCamera deviceCamera) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text(deviceCamera.deviceName!, style: const TextStyle(fontSize: 16)),
          Text(deviceCamera.location!, style: const TextStyle(fontSize: 16)),
          // Text('Last Updated: ${deviceCamera.location!}', style: const TextStyle(fontSize: 16)),
          const Gap(10),
          Expanded(
            child: Image.memory(
              base64Decode(deviceCamera.image!),
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    ),
  );
}
