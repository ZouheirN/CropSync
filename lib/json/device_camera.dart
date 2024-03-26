// To parse this JSON data, do
//
//     final deviceCamera = deviceCameraFromJson(jsonString);

import 'dart:convert';

List<DeviceCamera> deviceCameraFromJson(List list) => List<DeviceCamera>.from(list.map((x) => DeviceCamera.fromJson(x)));

String deviceCameraToJson(List<DeviceCamera> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DeviceCamera {
  String? deviceId;
  String? name;
  String? location;
  String? cropName;
  DateTime? cameraCollectionDate;
  String? image;

  DeviceCamera({
    this.deviceId,
    this.name,
    this.location,
    this.cropName,
    this.cameraCollectionDate,
    this.image,
  });

  factory DeviceCamera.fromJson(Map<String, dynamic> json) => DeviceCamera(
    deviceId: json["deviceId"],
    name: json["name"],
    location: json["location"],
    cropName: json["cropName"],
    cameraCollectionDate: json["cameraCollectionDate"] == null ? null : DateTime.parse(json["cameraCollectionDate"]),
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "deviceId": deviceId,
    "name": name,
    "location": location,
    "cropName": cropName,
    "cameraCollectionDate": cameraCollectionDate?.toIso8601String(),
    "image": image,
  };
}
