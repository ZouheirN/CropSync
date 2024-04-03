// To parse this JSON data, do
//
//     final cropChart = cropChartFromJson(jsonString);

import 'dart:convert';

CropChart cropChartFromJson(Map<String, dynamic> json) =>
    CropChart.fromJson(json);

String cropChartToJson(CropChart data) => json.encode(data.toJson());


class CropChart {
  List<CropChartDatum>? data;

  CropChart({
    this.data,
  });

  factory CropChart.fromJson(Map<String, dynamic> json) => CropChart(
    data: json["data"] == null ? [] : List<CropChartDatum>.from(json["data"]!.map((x) => CropChartDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class CropChartDatum {
  String? deviceId;
  String? deviceName;
  String? location;
  String? cropName;
  List<double>? nitrogen;
  List<double>? phosphorus;
  List<double>? potassium;
  List<double>? temperature;
  List<double>? ph;
  List<double>? moisture;
  List<DateTime>? collectionDates;

  CropChartDatum({
    this.deviceId,
    this.deviceName,
    this.location,
    this.cropName,
    this.nitrogen,
    this.phosphorus,
    this.potassium,
    this.temperature,
    this.ph,
    this.moisture,
    this.collectionDates,
  });

  factory CropChartDatum.fromJson(Map<String, dynamic> json) => CropChartDatum(
    deviceId: json["deviceId"],
    deviceName: json["deviceName"],
    location: json["location"],
    cropName: json["cropName"],
    nitrogen: json["nitrogen"] == null ? [] : List<double>.from(json["nitrogen"]!.map((x) => x?.toDouble())),
    phosphorus: json["phosphorus"] == null ? [] : List<double>.from(json["phosphorus"]!.map((x) => x?.toDouble())),
    potassium: json["potassium"] == null ? [] : List<double>.from(json["potassium"]!.map((x) => x?.toDouble())),
    temperature: json["temperature"] == null ? [] : List<double>.from(json["temperature"]!.map((x) => x?.toDouble())),
    ph: json["ph"] == null ? [] : List<double>.from(json["ph"]!.map((x) => x?.toDouble())),
    moisture: json["moisture"] == null ? [] : List<double>.from(json["moisture"]!.map((x) => x?.toDouble())),
    collectionDates: json["collectionDates"] == null ? [] : List<DateTime>.from(json["collectionDates"]!.map((x) => DateTime.parse(x))),
  );

  Map<String, dynamic> toJson() => {
    "deviceId": deviceId,
    "deviceName": deviceName,
    "location": location,
    "cropName": cropName,
    "nitrogen": nitrogen == null ? [] : List<dynamic>.from(nitrogen!.map((x) => x)),
    "phosphorus": phosphorus == null ? [] : List<dynamic>.from(phosphorus!.map((x) => x)),
    "potassium": potassium == null ? [] : List<dynamic>.from(potassium!.map((x) => x)),
    "temperature": temperature == null ? [] : List<dynamic>.from(temperature!.map((x) => x)),
    "ph": ph == null ? [] : List<dynamic>.from(ph!.map((x) => x)),
    "moisture": moisture == null ? [] : List<dynamic>.from(moisture!.map((x) => x)),
    "collectionDates": collectionDates == null ? [] : List<dynamic>.from(collectionDates!.map((x) => x.toIso8601String())),
  };
}
