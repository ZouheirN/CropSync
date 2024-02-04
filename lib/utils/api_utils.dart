import 'package:cropsync/models/user_model.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:flutter/material.dart';
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
  invalidToken,
  noDevices,
}