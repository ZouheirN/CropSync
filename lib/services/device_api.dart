import 'dart:convert';

import 'package:cropsync/json/crop_chart.dart';
import 'package:cropsync/json/device.dart';
import 'package:cropsync/json/device_camera.dart';
import 'package:cropsync/json/device_camera_history.dart';
import 'package:cropsync/json/soil_data.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/services/user_token.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      logger.e(e.response?.data);

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
      logger.e(e.response?.data);

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

      logger.i(devices);

      for (final device in devices) {
        deviceList.add(Device.fromJson(device));
      }

      return deviceList;
    } on DioException catch (e) {
      logger.e(e.response?.data);

      return null;
    }
  }

  static Future<dynamic> getDeviceCamera() async {
    final token = await UserToken.getToken();
    if (token == '') return ReturnTypes.invalidToken;

    try {
      final response = await dio.get(
        '$apiUrl/user/devices/image',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return deviceCameraFromJson(response.data);
    } on DioException catch (e) {
      logger.e(e.response?.data);

      return null;
    }
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
      logger.e(e.response?.data);

      if (e.response?.data['error'] == "UnAuthorized Access!") {
        return ReturnTypes.fail;
      } else if (e.response?.data['error'] == "Expired token") {
        return ReturnTypes.invalidToken;
      }

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> setDeviceCrop({
    required String deviceId,
    required String name,
    required String imageUrl,
  }) async {
    final token = await UserToken.getToken();
    if (token == '') return ReturnTypes.invalidToken;

    try {
      final response = await dio.post(
        '$apiUrl/user/set/crop',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
        data: {
          'name': name,
          'deviceId': deviceId,
          'profile': imageUrl,
        },
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;
      logger.e(e.response?.data);

      if (e.response?.data['error'] == "UnAuthorized Access!") {
        return ReturnTypes.fail;
      } else if (e.response?.data['error'] == "Expired token") {
        return ReturnTypes.invalidToken;
      }

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> getCropChartData() async {
    String jsonString = await rootBundle.loadString('assets/chart_data.json');
    final data = json.decode(jsonString);

    return cropChartFromJson(data);
  }

  static Future<dynamic> getLatestSoilData(String deviceId) async {
    final token = await UserToken.getToken();
    if (token == '') return ReturnTypes.invalidToken;

    try {
      final response = await dio.get(
        '$apiUrl/user/$deviceId/soil/reading',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return soilDataFromJson(response.data);
    } on DioException catch (e) {
      logger.e(e.response?.data);

      return null;
    }
  }

  static Future<dynamic> getDeviceImages(String deviceId, int page) async {
    final token = await UserToken.getToken();
    if (token == '') return ReturnTypes.invalidToken;

    try {
      final response = await dio.get(
        '$apiUrl/user/$deviceId/images?page=$page',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      logger.i(response.data['pagination']);

      if (response.data['pagination']['totalPages'] < page) {
        return ReturnTypes.endOfPages;
      }

      return deviceCameraHistoryFromJson(response.data);
    } on DioException catch (e) {
      logger.e(e.response?.data);

      return null;
    }
  }
}
