// To parse this JSON data, do
//
//     final weather = weatherFromJson(jsonString);

import 'dart:convert';

List<Weather> weatherFromJson(List<dynamic> list) =>
    List<Weather>.from(list.map((x) => Weather.fromJson(x)));

String weatherToJson(List<Weather> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Weather {
  String? name;
  String? deviceId;
  String? location;
  int? tempC;
  Condition? condition;
  int? windKph;
  int? windDegree;
  String? windDr;
  double? precipMm;
  int? humidity;
  int? cloud;
  int? feelslikeC;

  Weather({
    this.name,
    this.deviceId,
    this.location,
    this.tempC,
    this.condition,
    this.windKph,
    this.windDegree,
    this.windDr,
    this.precipMm,
    this.humidity,
    this.cloud,
    this.feelslikeC,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        name: json["name"],
        deviceId: json["deviceId"],
        location: json["location"],
        tempC: json["temp_c"],
        condition: json["condition"] == null
            ? null
            : Condition.fromJson(json["condition"]),
        windKph: json["wind_kph"],
        windDegree: json["wind_degree"],
        windDr: json["wind_dr"],
        precipMm: json["precip_mm"]?.toDouble(),
        humidity: json["humidity"],
        cloud: json["cloud"],
        feelslikeC: json["feelslike_c"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "deviceId": deviceId,
        "location": location,
        "temp_c": tempC,
        "condition": condition?.toJson(),
        "wind_kph": windKph,
        "wind_degree": windDegree,
        "wind_dr": windDr,
        "precip_mm": precipMm,
        "humidity": humidity,
        "cloud": cloud,
        "feelslike_c": feelslikeC,
      };
}

class Condition {
  String? text;
  String? icon;

  Condition({
    this.text,
    this.icon,
  });

  factory Condition.fromJson(Map<String, dynamic> json) => Condition(
        text: json["text"],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "icon": icon,
      };
}
