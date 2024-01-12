import 'dart:convert';

import 'package:hive/hive.dart';

part 'weather.g.dart';

List<Weather> weatherFromJson(List<dynamic> json) =>
    List<Weather>.from(json.map((x) => Weather.fromJson(x)));

String weatherToJson(List<Weather> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 4)
class Weather {
  @HiveField(0)
  int? deviceId;
  @HiveField(1)
  String? deviceName;
  @HiveField(2)
  String? location;
  @HiveField(3)
  int? humidity;
  @HiveField(4)
  int? temperature;
  @HiveField(5)
  int? moisture;

  Weather({
    this.deviceId,
    this.deviceName,
    this.location,
    this.humidity,
    this.temperature,
    this.moisture,
  });

  Weather.fromJson(Map<String, dynamic> json) {
    deviceId = json['deviceId'];
    deviceName = json['deviceName'];
    location = json['location'];
    humidity = json['humidity'];
    temperature = json['temperature'];
    moisture = json['moisture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceId'] = deviceId;
    data['deviceName'] = deviceName;
    data['location'] = location;
    data['humidity'] = humidity;
    data['temperature'] = temperature;
    data['moisture'] = moisture;
    return data;
  }
}
