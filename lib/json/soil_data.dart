// To parse this JSON data, do
//
//     final soilData = soilDataFromJson(jsonString);

import 'dart:convert';

SoilData soilDataFromJson(Map<String, dynamic> json) => SoilData.fromJson(json);

String soilDataToJson(SoilData data) => json.encode(data.toJson());

class SoilData {
  String? deviceId;
  String? name;
  DateTime? sensorCollectionDate;
  double? nitrogen;
  double? phosphorus;
  double? potassium;
  double? ph;
  double? humidity;
  double? temperature;

  SoilData({
    this.deviceId,
    this.name,
    this.sensorCollectionDate,
    this.nitrogen,
    this.phosphorus,
    this.potassium,
    this.ph,
    this.humidity,
    this.temperature,
  });

  factory SoilData.fromJson(Map<String, dynamic> json) => SoilData(
    deviceId: json["deviceId"],
    name: json["name"],
    sensorCollectionDate: json["sensorCollectionDate"] == null ? null : DateTime.parse(json["sensorCollectionDate"]),
    nitrogen: json["nitrogen"]?.toDouble(),
    phosphorus: json["phosphorus"]?.toDouble(),
    potassium: json["potassium"]?.toDouble(),
    ph: json["ph"]?.toDouble(),
    humidity: json["humidity"]?.toDouble(),
    temperature: json["temperature"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "deviceId": deviceId,
    "name": name,
    "sensorCollectionDate": sensorCollectionDate?.toIso8601String(),
    "nitrogen": nitrogen,
    "phosphorus": phosphorus,
    "potassium": potassium,
    "ph": ph,
    "humidity": humidity,
    "temperature": temperature,
  };
}
