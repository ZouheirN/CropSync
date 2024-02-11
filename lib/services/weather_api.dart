import 'dart:convert';

import 'package:cropsync/json/weather.dart';
import 'package:cropsync/json/weather_forecast.dart';
import 'package:cropsync/services/user_token.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class WeatherApi {
  static final dio = Dio();

  static final apiUrl = dotenv.env['API_URL'];

  static Future<dynamic> getWeatherData() async {
    final token = await UserToken.getToken();
    if (token == '') return ReturnTypes.invalidToken;

    try {
      final response = await dio.get(
        '$apiUrl/user/daily/weather',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return weatherFromJson(response.data);
    } on DioException catch (e) {
      Logger().e(e.response?.data);

      return null;
    }
  }

  static Future<dynamic> getWeatherForecastData({int days = 3}) async {
    final token = await UserToken.getToken();
    if (token == '') return ReturnTypes.invalidToken;

    try {
      final response = await dio.get(
        '$apiUrl/user/weather/forecast/$days',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return weatherForecastFromJson(response.data);
    } on DioException catch (e) {
      Logger().e(e.response?.data);

      return null;
    }
  }
}
