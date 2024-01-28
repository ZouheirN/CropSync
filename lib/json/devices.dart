// To parse this JSON data, do
//
//     final devices = devicesFromJson(jsonString);

import 'dart:convert';

List<Devices> devicesFromJson(List<dynamic> json) =>
    List<Devices>.from(json.map((x) => Devices.fromJson(x)));

String devicesToJson(List<Devices> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Devices {
  String? id;
  String? name;
  String? code;
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

class Crop {
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
