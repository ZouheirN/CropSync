import 'dart:convert';

import 'package:cropsync/json/device.dart';
import 'package:cropsync/json/device_camera.dart';
import 'package:cropsync/services/user_token.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class DeviceApi {
  static final dio = Dio();

  static final apiUrl = dotenv.env['API_URL'];

  static Future<dynamic> addDevice({
    required String name,
    required String location,
    required String code,
  }) async {
    final token = await UserToken.getToken();
    if (token == '') return ReturnTypes.invalidToken;

    try {
      final response = await dio.post(
        '$apiUrl/user/add/device',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
        data: {
          'name': name,
          'location': location,
          'code': code,
        },
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;
      Logger().e(e.response?.data);

      if (e.response?.data['error'] == "UnAuthorized Access!") {
        return ReturnTypes.fail;
      } else if (e.response?.data['error'] == "Expired token") {
        return ReturnTypes.invalidToken;
      }

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> editDevice({
    required String deviceId,
    required String name,
    required String location,
  }) async {
    final token = await UserToken.getToken();
    if (token == '') return ReturnTypes.invalidToken;

    try {
      final response = await dio.patch(
        '$apiUrl/user/device',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
        data: {
          "deviceId": deviceId,
          "name": name,
          "location": location,
        },
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;
      Logger().e(e.response?.data);

      if (e.response?.data['error'] == "UnAuthorized Access!") {
        return ReturnTypes.fail;
      } else if (e.response?.data['error'] == "Expired token") {
        return ReturnTypes.invalidToken;
      }

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> getDevices() async {
    final token = await UserToken.getToken();
    if (token == '') return ReturnTypes.invalidToken;

    try {
      final response = await dio.get(
        '$apiUrl/user/devices',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      final devices = response.data['devices'];
      final List<Device> deviceList = [];

      for (final device in devices) {
        deviceList.add(Device.fromJson(device));
      }

      return deviceList;
    } on DioException catch (e) {
      Logger().e(e.response?.data);

      return null;
    }
  }

  static Future<dynamic> getDeviceCamera() async {
    String jsonString =
        await rootBundle.loadString('assets/device_camera.json');
    final data = json.decode(jsonString);

    return deviceCameraFromJson(data);
  }

  static Future<dynamic> deleteDevice({required String deviceId}) async {
    final token = await UserToken.getToken();
    if (token == '') return ReturnTypes.invalidToken;

    try {
      final response = await dio.delete(
        '$apiUrl/user/device',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
        data: {
          'deviceId': deviceId,
        },
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;
      Logger().e(e.response?.data);

      if (e.response?.data['error'] == "UnAuthorized Access!") {
        return ReturnTypes.fail;
      } else if (e.response?.data['error'] == "Expired token") {
        return ReturnTypes.invalidToken;
      }

      return ReturnTypes.fail;
    }
  }
}
