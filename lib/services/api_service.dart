import 'dart:convert';

import 'package:cropsync/json/devices.dart';
import 'package:cropsync/json/user.dart';
import 'package:cropsync/models/image_model.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:watch_it/watch_it.dart';

enum ReturnTypes {
  success,
  error,
  fail,
  alreadyConfigured,
  hasNotBeenConfigured
}

class ApiRequests {
  static final dio = Dio();

  static final apiUrl = dotenv.env['API_URL'];

  static Future<dynamic> login(String email, String password) async {
    try {
      final response = await dio.post(
        '$apiUrl/user/login}',
        data: {
          'email': email,
          'password': password,
        },
      );

      return response.data;
    } on DioException catch (e) {
      Logger().e(e);

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> getWeatherData() async {
    String jsonString = await rootBundle.loadString('assets/weather.json');
    final data = json.decode(jsonString);

    return data;
  }

  static Future<dynamic> getDeviceCamera() async {
    String jsonString =
        await rootBundle.loadString('assets/device_camera.json');
    final data = json.decode(jsonString);

    return data;
  }

  static Future<dynamic> uploadDiseaseImage({
    required String image,
    required int index,
  }) async {
    di<ImageModel>().setResult(index, 'Uploading...');

    try {
      await dio.post(
        'https://httpbin.org/post',
        data: {
          'image': image,
        },
        onSendProgress: (int sent, int total) {
          di<ImageModel>().setProgress(index, sent / total);

          if (sent == total) {
            di<ImageModel>().setResult(index, 'Processing...');
          }
        },
      );
    } on DioException catch (e) {
      Logger().e(e);
      di<ImageModel>().setResult(index, 'Upload Failed');
    }
  }

  static Future<dynamic> addDeviceConfiguration(String deviceCode) async {
    // todo get activation key from api

    final email = di<UserModel>().user.email;

    try {
      final response = await dio.post(
        'http://comitup-$deviceCode:3000/',
        data: {
          "email": email,
          "activationKey": "todo",
        },
      );

      if (response.statusCode == 200) return ReturnTypes.success;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return ReturnTypes.alreadyConfigured;
      } else if (e.response?.statusCode == 500) {
        return ReturnTypes.error;
      }

      Logger().e(e);

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> deleteDeviceConfiguration(Devices device) async {
    // todo delete from api

    try {
      final response = await dio.delete(
        'http://comitup-${device.code}:3000/',
      );

      if (response.statusCode == 200) return ReturnTypes.success;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ReturnTypes.hasNotBeenConfigured;
      } else if (e.response?.statusCode == 500) {
        return ReturnTypes.error;
      }

      Logger().e(e);

      return ReturnTypes.fail;
    }
  }
}
