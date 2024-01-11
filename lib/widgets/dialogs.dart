import 'dart:async';

import 'package:cropsync/main.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class Dialogs {
  static void showErrorDialog(String title, String text, BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      animType: QuickAlertAnimType.slideInUp,
      title: title,
      text: text,
      backgroundColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.white
          : const Color(0xFF1B2522),
      textColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.black
          : Colors.white,
      titleColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.black
          : Colors.white,
      confirmBtnColor: Colors.green,
    );
  }

  static Future<bool> showConfirmationDialog(
      String title, String text, BuildContext context) async {
    Completer<bool> completer = Completer<bool>();

    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: title,
      text: text,
      confirmBtnText: 'Yes',
      showCancelBtn: true,
      cancelBtnText: 'No',
      confirmBtnColor: Colors.green,
      animType: QuickAlertAnimType.slideInUp,
      backgroundColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.white
          : const Color(0xFF1B2522),
      textColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.black
          : Colors.white,
      titleColor: MyApp.themeNotifier.value == ThemeMode.light
          ? Colors.black
          : Colors.white,
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        completer.complete(true);
      },
      onCancelBtnTap: () {
        Navigator.of(context).pop();
        completer.complete(false);
      },
    );

    return completer.future;
  }
}
