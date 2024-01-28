import 'dart:convert';

List<Weather> weatherFromJson(List<dynamic> json) =>
    List<Weather>.from(json.map((x) => Weather.fromJson(x)));

String weatherToJson(List<Weather> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Weather {
  int? deviceId;
  String? deviceName;
  String? location;
  int? humidity;
  int? temperature;
  int? moisture;
  List<String>? alerts;

  Weather({
    this.deviceId,
    this.deviceName,
    this.location,
    this.humidity,
    this.temperature,
    this.moisture,
    this.alerts
  });

  Weather.fromJson(Map<String, dynamic> json) {
    deviceId = json['deviceId'];
    deviceName = json['deviceName'];
    location = json['location'];
    humidity = json['humidity'];
    temperature = json['temperature'];
    moisture = json['moisture'];
    alerts = json['alerts'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceId'] = deviceId;
    data['deviceName'] = deviceName;
    data['location'] = location;
    data['humidity'] = humidity;
    data['temperature'] = temperature;
    data['moisture'] = moisture;
    data['alerts'] = alerts;
    return data;
  }
}
