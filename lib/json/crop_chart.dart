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
        data: json["data"] == null
            ? []
            : List<CropChartDatum>.from(
                json["data"]!.map((x) => CropChartDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CropChartDatum {
  String? deviceName;
  String? cropName;
  String? location;
  List<double>? moisture;
  List<double>? nitrogen;
  List<double>? ph;
  List<double>? phosphorus;
  List<double>? potassium;
  List<double>? temperature;

  CropChartDatum({
    this.deviceName,
    this.cropName,
    this.location,
    this.moisture,
    this.nitrogen,
    this.ph,
    this.phosphorus,
    this.potassium,
    this.temperature,
  });

  factory CropChartDatum.fromJson(Map<String, dynamic> json) => CropChartDatum(
        deviceName: json["deviceName"],
        cropName: json["cropName"],
        location: json["location"],
        moisture: json["moisture"] == null
            ? []
            : List<double>.from(json["moisture"]!.map((x) => x?.toDouble())),
        nitrogen: json["nitrogen"] == null
            ? []
            : List<double>.from(json["nitrogen"]!.map((x) => x?.toDouble())),
        ph: json["ph"] == null
            ? []
            : List<double>.from(json["ph"]!.map((x) => x?.toDouble())),
        phosphorus: json["phosphorus"] == null
            ? []
            : List<double>.from(json["phosphorus"]!.map((x) => x?.toDouble())),
        potassium: json["potassium"] == null
            ? []
            : List<double>.from(json["potassium"]!.map((x) => x?.toDouble())),
        temperature: json["temperature"] == null
            ? []
            : List<double>.from(json["temperature"]!.map((x) => x?.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "deviceName": deviceName,
        "cropName": cropName,
        "location": location,
        "moisture":
            moisture == null ? [] : List<dynamic>.from(moisture!.map((x) => x)),
        "nitrogen":
            nitrogen == null ? [] : List<dynamic>.from(nitrogen!.map((x) => x)),
        "ph": ph == null ? [] : List<dynamic>.from(ph!.map((x) => x)),
        "phosphorus": phosphorus == null
            ? []
            : List<dynamic>.from(phosphorus!.map((x) => x)),
        "potassium": potassium == null
            ? []
            : List<dynamic>.from(potassium!.map((x) => x)),
        "temperature": temperature == null
            ? []
            : List<dynamic>.from(temperature!.map((x) => x)),
      };
}
