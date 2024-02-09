import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class OtherVars extends ChangeNotifier{
  final otherVarsBox = Hive.box('otherVars');

  bool get autoRefresh => otherVarsBox.get('autoRefresh') ?? false;

  set autoRefresh(bool value) {
    otherVarsBox.put('autoRefresh', value);
  }

  bool _showBadge = false;

  bool get showBadge => _showBadge;

  set showBadge(bool value) {
    _showBadge = value;
    notifyListeners();
  }
}