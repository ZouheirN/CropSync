// To parse this JSON data, do
//
//     final device = deviceFromJson(jsonString);

import 'dart:convert';

import 'package:cropsync/json/crop.dart';

Device deviceFromJson(String str) => Device.fromJson(json.decode(str));

String deviceToJson(Device data) => json.encode(data.toJson());

class Device {
  bool? isConnected;
  String? deviceId;
  String? location;
  String? name;
  String? code;
  Crop? crop;

  Device({
    this.isConnected,
    this.deviceId,
    this.location,
    this.name,
    this.code,
    this.crop,
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
    "location":location,
    "name": name,
    "code": code,
    "crop": crop?.toJson(),
  };
}
