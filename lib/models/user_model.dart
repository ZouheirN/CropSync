import 'package:cropsync/json/user.dart';
import 'package:cropsync/services/user_token.dart';
import 'package:cropsync/utils/other_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:watch_it/watch_it.dart';

class UserModel extends ChangeNotifier {
  final userInfoBox = Hive.box('userInfo');
  final devicesBox = Hive.box('devices');

  User get user => _user;

  User _user = User(
    token: "",
    fullName: "",
    email: "",
    isVerified: false,
  );

  set user(User user) {
    _user = user;
    userInfoBox.put('user', user);
    UserToken.setToken(user.token ?? "");
    OneSignal.login(user.externalId!);
    notifyListeners();
  }

  void logout() {
    _user = User(
      token: "",
      fullName: "",
      email: "",
      isVerified: false,
    );
    userInfoBox.delete('user');
    devicesBox.delete('devices');
    di<OtherVars>().autoRefresh = false;
    di<OtherVars>().showBadge = false;
    UserToken.deleteToken();
    OneSignal.logout();
    notifyListeners();
  }

  void setProgress(double progress) {
    _user.uploadProgress = progress;
    // _user = User(
    //   token: _user.token,
    //   uploadProgress: progress,
    //   isVerified: _user.isVerified,
    //   email: _user.email,
    //   fullName: _user.fullName,
    //   profilePicture: _user.profilePicture,
    // );
    notifyListeners();
  }

  void setImage(Uint8List image) {
    _user.profilePicture = image;
    // _user = User(
    //   token: _user.token,
    //   uploadProgress: _user.uploadProgress,
    //   isVerified: _user.isVerified,
    //   email: _user.email,
    //   fullName: _user.fullName,
    //   profilePicture: image,
    // );
    userInfoBox.put('user', _user);
    notifyListeners();
  }

  void removeImage() {
    _user.profilePicture = null;
    // _user = User(
    //   token: _user.token,
    //   uploadProgress: _user.uploadProgress,
    //   isVerified: _user.isVerified,
    //   email: _user.email,
    //   fullName: _user.fullName,
    //   profilePicture: null,
    // );
    userInfoBox.put('user', _user);
    notifyListeners();
  }
}
