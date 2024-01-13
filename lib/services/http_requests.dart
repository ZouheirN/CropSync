import 'dart:convert';

import 'package:flutter/services.dart';

enum ReturnTypes {
  success,
  error,
  fail,
}

class ApiRequests {
  static Future<dynamic> checkCredentials(
      String username, String password) async {
    String jsonString = await rootBundle.loadString('assets/user.json');
    final data = json.decode(jsonString);

    return data;
  }

  static Future<dynamic> getWeatherData() async {
    String jsonString = await rootBundle.loadString('assets/weather.json');
    final data = json.decode(jsonString);

    return data;
  }

  static Future<dynamic> getDeviceCamera() async {
    String jsonString = await rootBundle.loadString('assets/device_camera.json');
    final data = json.decode(jsonString);

    return data;
  }
}
