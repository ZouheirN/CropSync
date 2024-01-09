import 'package:cropsync/json/user.dart';
import 'package:cropsync/services/user_token.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class UserModel extends ChangeNotifier {
  final userInfoBox = Hive.box('userInfo');

  User get user => _user;

  User _user = User(
    fullName: "",
    email: "",
    microId: [],
    isVerified: false,
  );

  set user(User user) {
    _user = user;
    userInfoBox.put('user', user);
    notifyListeners();
  }

  void logout() {
    _user = User(
      fullName: "",
      email: "",
      microId: [],
      isVerified: false,
    );
    userInfoBox.delete('user');
    UserToken.deleteToken();
    notifyListeners();
  }
}
