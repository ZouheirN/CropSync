import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserToken {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static setToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String> getToken() async {
    return await _storage.read(key: 'token') ?? '';
  }

  static deleteToken() async {
    await _storage.delete(key: 'token');
  }
}
