import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserInfoModel extends ChangeNotifier {
  final _userInfoBox = Hive.box('userInfo');

  String get fullName => _fullName;

  String get email => _email;

  List<String> get microId => _microId;

  bool get isVerified => _isVerified;

  String _fullName = "";
  String _email = "";
  List<String> _microId = [];
  bool _isVerified = false;

  set fullName(String fullName) {
    _fullName = fullName;
    _userInfoBox.put('fullName', fullName);
    notifyListeners();
  }

  set email(String email) {
    _email = email;
    _userInfoBox.put('email', email);
    notifyListeners();
  }

  set microId(List<String> microId) {
    _microId = microId;
    _userInfoBox.put('microId', microId);
    notifyListeners();
  }

  set isVerified(bool isVerified) {
    _isVerified = isVerified;
    _userInfoBox.put('isVerified', isVerified);
    notifyListeners();
  }
}
