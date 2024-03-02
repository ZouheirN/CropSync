import 'package:cropsync/json/user.dart';
import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/services/user_token.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cropsync/main.dart';
import 'package:watch_it/watch_it.dart';

class UserApi {
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

      return userFromJson(response.data);
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      logger.e(e.response?.data);

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

      logger.e(e.response?.data);

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

      return userFromJson(response.data);
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      if (e.response?.data['error'] == "UnAuthorized Access!") {
        return ReturnTypes.fail;
      } else if (e.response?.data['error'] == "Expired token") {
        return ReturnTypes.invalidToken;
      }

      logger.e(e.response?.data);

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

      if (e.response?.data['error'] == "UnAuthorized Access!") {
        return ReturnTypes.fail;
      } else if (e.response?.data['error'] == "Expired token") {
        return ReturnTypes.invalidToken;
      }

      logger.e(e.response?.data);
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

      if (e.response?.data['error'] == "UnAuthorized Access!") {
        return ReturnTypes.fail;
      } else if (e.response?.data['error'] == "Expired token") {
        return ReturnTypes.invalidToken;
      }

      logger.e(e.response?.data);
      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> sendResetPasswordOtp({
    required String email,
  }) async {
    try {
      await dio.post(
        '$apiUrl/user/Request/ResetPassword',
        data: {
          'email': email,
        },
      );

      return ReturnTypes.success;
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      logger.e(e.response?.data);

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> verifyResetPasswordOtp(
      {required String pin, required String email}) async {
    try {
      final response = await dio.post(
        '$apiUrl/ResetPassword',
        data: {
          'pin': pin,
          'email': email,
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

      logger.e(e.response?.data);

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> resetPassword(
      {required String password, required String token}) async {
    try {
      final response = await dio.post(
        '$apiUrl/user/ResetPassword',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
        data: {
          'password': password,
        },
      );

      return userFromJson(response.data);
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      if (e.response?.data['error'] == "UnAuthorized Access!") {
        return ReturnTypes.fail;
      } else if (e.response?.data['error'] == "Expired token") {
        return ReturnTypes.invalidToken;
      }

      logger.e(e.response?.data);

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> changePassword(
      {required String oldPassword, required String newPassword}) async {
    final String token = await UserToken.getToken();
    if (token == '') {
      return ReturnTypes.invalidToken;
    }

    try {
      Response response;
      response = await dio.post(
        '$apiUrl/user/ChangePassword',
        data: {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      return userFromJson(response.data);
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      if (e.response!.data['error'] == 'Invalid Password!') {
        return ReturnTypes.invalidPassword;
      } else if (e.response!.data['error'] == 'Expired token') {
        return ReturnTypes.invalidToken;
      }

      return ReturnTypes.fail;
    }
  }
}
