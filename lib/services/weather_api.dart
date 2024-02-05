import 'dart:convert';

import 'package:cropsync/json/weather.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherApi {
  static final dio = Dio();

  static final apiUrl = dotenv.env['API_URL'];

  static Future<dynamic> getWeatherData() async {
    String jsonString = await rootBundle.loadString('assets/weather.json');
    final data = json.decode(jsonString);

    return weatherFromJson(data);
  }
}
