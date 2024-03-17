// To parse this JSON data, do
//
//     final device = deviceFromJson(jsonString);

import 'dart:convert';

import 'package:cropsync/json/crop.dart';
import 'package:hive/hive.dart';

part 'device.g.dart';

Device deviceFromJson(String str) => Device.fromJson(json.decode(str));

String deviceToJson(Device data) => json.encode(data.toJson());

@HiveType(typeId: 2)
class Device {
  @HiveField(0)
  bool? isConnected;
  @HiveField(1)
  String? deviceId;
  @HiveField(2)
  String? location;
  @HiveField(3)
  String? name;
  @HiveField(4)
  String? code;
  @HiveField(5)
  Crop? crop;
  @HiveField(6)
  int? soilFrequency;
  @HiveField(7)
  int? imageFrequency;

  Device({
    this.isConnected,
    this.deviceId,
    this.location,
    this.name,
    this.code,
    this.crop,
    this.soilFrequency,
    this.imageFrequency,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        isConnected: json["isConnected"],
        deviceId: json["deviceId"],
        location: json["location"],
        name: json["name"],
        code: json["code"],
        crop: json["crop"] == null ? null : Crop.fromJson(json["crop"]),
      );

  Map<String, dynamic> toJson() => {
        "isConnected": isConnected,
        "deviceId": deviceId,
        "location": location,
        "name": name,
        "code": code,
        "crop": crop?.toJson(),
      };
}
