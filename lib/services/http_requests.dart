import 'dart:convert';

import 'package:flutter/services.dart';

enum ReturnTypes {
  success,
  error,
  fail,
}

Future<String> _loadData() async {
  return await rootBundle.loadString('assets/user.json');
}

class ApiRequests {
  static Future<dynamic> checkCredentials(
      String username, String password) async {
    String jsonString = await _loadData();
    final data = json.decode(jsonString);

    return data;
  }
}
