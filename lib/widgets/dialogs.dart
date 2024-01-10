import 'package:cropsync/main.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

void showErrorDialog(String title, String text, BuildContext context) {
  QuickAlert.show(
    context: context,
    type: QuickAlertType.error,
    animType: QuickAlertAnimType.slideInUp,
    title: title,
    text: text,
    backgroundColor: MyApp.themeNotifier.value == ThemeMode.light
        ? Colors.white
        : const Color.fromARGB(255, 66, 66, 66),
    textColor: MyApp.themeNotifier.value == ThemeMode.light
        ? Colors.black
        : Colors.white,
    titleColor: MyApp.themeNotifier.value == ThemeMode.light
        ? Colors.black
        : Colors.white,
    confirmBtnColor: Colors.green,
  );
}