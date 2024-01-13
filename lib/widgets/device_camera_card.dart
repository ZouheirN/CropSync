import 'dart:convert';

import 'package:cropsync/json/device_camera.dart';
import 'package:flutter/material.dart';

Widget deviceCameraCard(DeviceCamera deviceCamera) {
  return Card(
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
        ),
      ],
    ),
  );
}
