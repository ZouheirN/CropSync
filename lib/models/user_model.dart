import 'package:cropsync/json/user.dart';
import 'package:cropsync/services/user_token.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class UserModel extends ChangeNotifier {
  final userInfoBox = Hive.box('userInfo');

  User get user => _user;

  User _user = User(
    token: "",
    fullName: "",
    email: "",
    devices: [],
    isVerified: false,
  );

  set user(User user) {
    _user = user;
    userInfoBox.put('user', user);
    UserToken.setToken(user.token ?? "");
    notifyListeners();
  }

  void logout() {
    _user = User(
      token: "",
      fullName: "",
      email: "",
      devices: [],
      isVerified: false,
    );
    userInfoBox.delete('user');
    UserToken.deleteToken();
    // todo delete images
    notifyListeners();
  }

  void addDevice(int id, String name, String code) {
    _user.devices
        ?.add(Devices(id: id, crop: Crop(name: null), name: name, code: code));
    userInfoBox.put('user', user);
    notifyListeners();
  }

  void deleteDevice(int id) {
    _user.devices?.removeWhere((element) => element.id == id);
    userInfoBox.put('user', user);
    notifyListeners();
  }
}
