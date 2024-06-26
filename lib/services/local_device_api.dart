import 'dart:io';

import 'package:cropsync/main.dart';
import 'package:cropsync/models/ip_cache_model.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:dio/dio.dart';
import 'package:nsd/nsd.dart';
import 'package:watch_it/watch_it.dart';

final ipCaches = IpCacheModel();

class LocalDeviceApi {
  static final dio = Dio();

  static Future<String> getDeviceIp(String deviceCode,
      {bool forceNewFetch = false}) async {
    try {
      if (forceNewFetch == false) {
        // check if ip is cached, and if it is return it
        final ipCache = ipCaches.getIpCache(deviceCode);
        if (ipCache != '') {
          return ipCache;
        }
      }

      final discovery = await startDiscovery('_cropsync$deviceCode._tcp',
          ipLookupType: IpLookupType.v4);

      String ip = '';

      discovery.addListener(() {
        logger.i(discovery.services);
        ip = discovery.services.first.addresses!.first.address;
      });

      int timeout = 0;

      while (discovery.services.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
        timeout++;
        if (timeout > 75) {
          discovery.dispose();
          return '';
        }
      }

      discovery.dispose();

      // cache the ip
      ipCaches.addIpCache(ip: ip, deviceId: deviceCode);

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

      getDeviceIp(deviceCode, forceNewFetch: true);

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

      getDeviceIp(deviceCode, forceNewFetch: true);

      logger.e(e.response?.data);

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> startStreaming(
      String deviceCode, String phoneIp) async {
    try {
      final ip = await getDeviceIp(deviceCode);

      if (ip == '') {
        return ReturnTypes.fail;
      }

      await dio.post(
        'http://$ip:3000/start-streaming',
        data: {
          "ip": phoneIp,
        },
      );

      return ReturnTypes.success;
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      getDeviceIp(deviceCode, forceNewFetch: true);

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

      getDeviceIp(deviceCode, forceNewFetch: true);

      logger.e(e.response?.data);

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> water(String deviceCode, int seconds) async {
    try {
      final ip = await getDeviceIp(deviceCode);

      if (ip == '') {
        return ReturnTypes.fail;
      }

      await dio.post(
        'http://$ip:3000/water',
        data: {
          "seconds": seconds,
        },
      );

      return ReturnTypes.success;
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      getDeviceIp(deviceCode, forceNewFetch: true);

      logger.e(e.response?.data);

      return ReturnTypes.fail;
    }
  }
}
