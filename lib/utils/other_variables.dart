import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class OtherVars extends ChangeNotifier {
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

  final List<Map<String, dynamic>> frequency = [
    {'id': 1, 'label': 'Every 6 hours', 'value': 21600},
    {'id': 2, 'label': 'Every 12 hours', 'value': 43200},
    {'id': 3, 'label': 'Every 24 hours', 'value': 86400},
    {'id': 4, 'label': 'Every 3 days', 'value': 259200},
    {'id': 5, 'label': 'Every week', 'value': 604800},
    {'id': 6, 'label': 'Every 2 weeks', 'value': 1209600},
    {'id': 7, 'label': 'Every month', 'value': 2592000},
  ];
}
