// To parse this JSON data, do
//
//     final weatherForecast = weatherForecastFromJson(jsonString);

import 'dart:convert';

List<WeatherForecast> weatherForecastFromJson(List<dynamic> list) =>
    List<WeatherForecast>.from(list.map((x) => WeatherForecast.fromJson(x)));

String weatherForecastToJson(List<WeatherForecast> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WeatherForecast {
  String? name;
  String? deviceId;
  String? location;
  List<WeatherDatum>? weatherData;

  WeatherForecast({
    this.name,
    this.deviceId,
    this.location,
    this.weatherData,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) =>
      WeatherForecast(
        name: json["name"],
        deviceId: json["deviceId"],
        location: json["location"],
        weatherData: json["weatherData"] == null
            ? []
            : List<WeatherDatum>.from(
                json["weatherData"]!.map((x) => WeatherDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "deviceId": deviceId,
        "location": location,
        "weatherData": weatherData == null
            ? []
            : List<dynamic>.from(weatherData!.map((x) => x.toJson())),
      };
}

class WeatherDatum {
  DateTime? date;
  double? maxtempC;
  double? mintempC;
  double? avgtempC;
  double? maxwindKph;
  double? totalprecipIn;
  double? totalsnowCm;
  double? avghumidity;
  double? dailyWillItRain;
  double? dailyChanceOfRain;
  double? dailyWillItSnow;
  double? dailyChanceOfSnow;
  Condition? condition;

  WeatherDatum({
    this.date,
    this.maxtempC,
    this.mintempC,
    this.avgtempC,
    this.maxwindKph,
    this.totalprecipIn,
    this.totalsnowCm,
    this.avghumidity,
    this.dailyWillItRain,
    this.dailyChanceOfRain,
    this.dailyWillItSnow,
    this.dailyChanceOfSnow,
    this.condition,
  });

  factory WeatherDatum.fromJson(Map<String, dynamic> json) => WeatherDatum(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        maxtempC: json["maxtemp_c"]?.toDouble(),
        mintempC: json["mintemp_c"]?.toDouble(),
        avgtempC: json["avgtemp_c"]?.toDouble(),
        maxwindKph: json["maxwind_kph"]?.toDouble(),
        totalprecipIn: json["totalprecip_in"]?.toDouble(),
        totalsnowCm: json["totalsnow_cm"]?.toDouble(),
        avghumidity: json["avghumidity"]?.toDouble(),
        dailyWillItRain: json["daily_will_it_rain"]?.toDouble(),
        dailyChanceOfRain: json["daily_chance_of_rain"]?.toDouble(),
        dailyWillItSnow: json["daily_will_it_snow"]?.toDouble(),
        dailyChanceOfSnow: json["daily_chance_of_snow"]?.toDouble(),
        condition: json["condition"] == null
            ? null
            : Condition.fromJson(json["condition"]),
      );

  Map<String, dynamic> toJson() => {
        "date":
            "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "maxtemp_c": maxtempC,
        "mintemp_c": mintempC,
        "avgtemp_c": avgtempC,
        "maxwind_kph": maxwindKph,
        "totalprecip_in": totalprecipIn,
        "totalsnow_cm": totalsnowCm,
        "avghumidity": avghumidity,
        "daily_will_it_rain": dailyWillItRain,
        "daily_chance_of_rain": dailyChanceOfRain,
        "daily_will_it_snow": dailyWillItSnow,
        "daily_chance_of_snow": dailyChanceOfSnow,
        "condition": condition?.toJson(),
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
