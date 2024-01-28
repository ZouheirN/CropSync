import 'dart:convert';
import 'dart:io';

import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:watch_it/watch_it.dart';

class LocalDeviceApi {
  static final dio = Dio();

  static Future<String> getDeviceIp(String deviceCode) async {
    final addresses = await InternetAddress.lookup('comitup-$deviceCode');
    return addresses[0].address;
  }

  static Future<dynamic> addDeviceConfiguration(
      {required String deviceCode, required String activationKey}) async {
    final email = di<UserModel>().user.email;

    try {
      final ip = await getDeviceIp(deviceCode);

      final response = await dio.post(
        'http://$ip:3000/set',
        data: {
          "email": email,
          "activationKey": activationKey,
        },
      );

      if (response.statusCode == 200) return ReturnTypes.success;
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      if (e.response?.statusCode == 500) {
        return ReturnTypes.error;
      }

      Logger().e(e.response?.data);
      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> deleteDeviceConfiguration(
      {required String deviceCode}) async {
    try {
      final ip = await getDeviceIp(deviceCode);

      final response = await dio.delete(
        'http://$ip:3000/delete',
      );

      if (response.statusCode == 200) return ReturnTypes.success;
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      if (e.response?.statusCode == 404) {
        return ReturnTypes.hasNotBeenConfigured;
      } else if (e.response?.statusCode == 500) {
        return ReturnTypes.error;
      }

      Logger().e(e.response?.data);

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> isDeviceAlreadyConfigured(String deviceCode) async {
    try {
      final ip = await getDeviceIp(deviceCode);

      final response = await dio.get(
        'http://$ip:3000/check',
      );

      return response.data['exists'];
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      Logger().e(e.response?.data);

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> getLatestLocalCamera({required String deviceCode}) async {
    try {
      final ip = await getDeviceIp(deviceCode);

      final response = await dio.get(
        'http://$ip:3000/latest-image',
      );

      return response.data['base64Image'];
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      Logger().e(e.response?.data);

      return ReturnTypes.fail;
    }
  }
}