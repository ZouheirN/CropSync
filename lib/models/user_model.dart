import 'package:cropsync/json/user.dart';
import 'package:cropsync/services/user_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class UserModel extends ChangeNotifier {
  final userInfoBox = Hive.box('userInfo');

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
    UserToken.deleteToken();
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
