import 'dart:io';

import 'package:cropsync/main.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:dio/dio.dart';
import 'package:nsd/nsd.dart';
import 'package:watch_it/watch_it.dart';

class LocalDeviceApi {
  static final dio = Dio();

  static Future<String> getDeviceIp(String deviceCode) async {
    try {
      // final addresses = await InternetAddress.lookup('cropsync-999');
      // logger.i(addresses[0].address);
      // return addresses[0].address;

      final discovery = await startDiscovery('_cropsync$deviceCode._tcp',
          ipLookupType: IpLookupType.v4);

      String ip = '';

      discovery.addListener(() {
        // logger.i(utf8.decode(discovery.services.first.txt!['ip']!));
        // ip = utf8.decode(discovery.services.first.txt!['ip']!);
        logger.i(discovery.services);
        ip = discovery.services.first.addresses!.first.address;
      });

      int timeout = 0;

      while (discovery.services.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
        timeout++;
        if (timeout > 50) {
          discovery.dispose();
          return '';
        }
      }

      discovery.dispose();
      return ip;
    } on SocketException catch (e) {
      logger.e(e);
      return '';
    }
  }

  static Future<dynamic> addDeviceConfiguration(
      {required String deviceCode, required String activationKey}) async {
    final email = di<UserModel>().user.email;

    try {
      final ip = await getDeviceIp(deviceCode);

      if (ip == '') {
        return ReturnTypes.fail;
      }

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

      logger.e(e.response?.data);
      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> deleteDeviceConfiguration(
      {required String deviceCode}) async {
    try {
      final ip = await getDeviceIp(deviceCode);

      if (ip == '') {
        return ReturnTypes.fail;
      }

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

      logger.e(e.response?.data);

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> isDeviceAlreadyConfigured(String deviceCode) async {
    try {
      final ip = await getDeviceIp(deviceCode);

      if (ip == '') {
        return ReturnTypes.fail;
      }

      final response = await dio.get(
        'http://$ip:3000/check',
      );

      return response.data['exists'];
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      logger.e(e.response?.data);

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> startStreaming(String deviceCode, String ip) async {
    try {
      final ip = await getDeviceIp(deviceCode);

      if (ip == '') {
        return ReturnTypes.fail;
      }

      await dio.post(
        'http://$ip:3000/start-streaming',
        data: {
          "ip": ip,
        },
      );

      return ReturnTypes.success;
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      logger.e(e.response?.data);

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> stopStreaming(String deviceCode) async {
    try {
      final ip = await getDeviceIp(deviceCode);

      if (ip == '') {
        return ReturnTypes.fail;
      }

      await dio.post(
        'http://$ip:3000/stop-streaming',
      );

      return ReturnTypes.success;
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      logger.e(e.response?.data);

      return ReturnTypes.fail;
    }
  }
}
