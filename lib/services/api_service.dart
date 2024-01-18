import 'dart:convert';

import 'package:cropsync/json/devices.dart';
import 'package:cropsync/models/image_model.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/services/user_token.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:watch_it/watch_it.dart';

void invalidTokenResponse(BuildContext context) {
  di<UserModel>().logout();
  Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  Dialogs.showErrorDialog(
      'Error', 'Your session has expired. Please log in again.', context);
}

enum ReturnTypes {
  success,
  error,
  fail,
  alreadyConfigured,
  hasNotBeenConfigured,
  emailTaken,
  invalidToken
}

class ApiRequests {
  static final dio = Dio();

  static final apiUrl = dotenv.env['API_URL'];

  static Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '$apiUrl/user/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      Logger().e(e.response?.data);

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '$apiUrl/user/signup',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
        },
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response!.data['error'] == 'Email already in-use.') {
        return ReturnTypes.emailTaken;
      }

      Logger().e(e.response?.data);

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> verifyEmail(
      {required String pin, required String token}) async {
    try {
      final response = await dio.post(
        '$apiUrl/verifyEmail',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
        data: {
          'pin': pin,
        },
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      if (e.response?.data['error'] == "UnAuthorized Access!") {
        return ReturnTypes.fail;
      } else if (e.response?.data['error'] == "Expired token") {
        return ReturnTypes.invalidToken;
      }

      Logger().e(e.response?.data);

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> updateProfilePicture(
      {required String base64Image}) async {
    final token = await UserToken.getToken();
    if (token == '') return ReturnTypes.invalidToken;

    try {
      await dio.post(
        '$apiUrl/user/set/profile',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
        data: {
          'profilePicture': base64Image,
        },
        onSendProgress: (int sent, int total) {
          di<UserModel>().setProgress(sent / total);
        },
      );

      return ReturnTypes.success;
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

  static Future<dynamic> removeProfilePicture() async {
    final token = await UserToken.getToken();
    if (token == '') return ReturnTypes.invalidToken;

    try {
      await dio.delete(
        '$apiUrl/user/delete/profile',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return ReturnTypes.success;
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


  static Future<dynamic> getWeatherData() async {
    String jsonString = await rootBundle.loadString('assets/weather.json');
    final data = json.decode(jsonString);

    return data;
  }

  static Future<dynamic> getDeviceData() async {
    String jsonString = await rootBundle.loadString('assets/devices.json');
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
      if (e.response == null) return ReturnTypes.error;

      Logger().e(e.response?.data);
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
      if (e.response == null) return ReturnTypes.error;

      if (e.response?.statusCode == 409) {
        return ReturnTypes.alreadyConfigured;
      } else if (e.response?.statusCode == 500) {
        return ReturnTypes.error;
      }

      Logger().e(e.response?.data);

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
}
