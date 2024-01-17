// To parse this JSON data, do
//
//     final devices = devicesFromJson(jsonString);

import 'package:hive/hive.dart';
import 'dart:convert';

part 'devices.g.dart';

List<Devices> devicesFromJson(String str) => List<Devices>.from(json.decode(str).map((x) => Devices.fromJson(x)));

String devicesToJson(List<Devices> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 2)
class Devices {
  @HiveField(1)
  int? id;
  @HiveField(2)
  String? name;
  @HiveField(3)
  String? code;
  @HiveField(4)
  Crop? crop;

  Devices({
    this.id,
    this.name,
    this.code,
    this.crop,
  });

  factory Devices.fromJson(Map<String, dynamic> json) => Devices(
    id: json["id"],
    name: json["name"],
    code: json["code"],
    crop: json["crop"] == null ? null : Crop.fromJson(json["crop"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "crop": crop?.toJson(),
  };
}

@HiveType(typeId: 3)
class Crop {
  @HiveField(1)
  String? name;

  Crop({
    this.name,
  });

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
  };
}
