import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class UserPrefs extends ChangeNotifier {
  final userPrefsBox = Hive.box('userPrefs');

  List<String> _homeListItems = [
    'Weather',
    'Alerts',
    'Device Camera',
  ];

  List<String> get homeListItems => _homeListItems;

  set homeListItems(List<String> homeListItems) {
    _homeListItems = homeListItems;
    userPrefsBox.put('homeListItems', homeListItems);
    notifyListeners();
  }

  String _startPage = 'Home';

  String get startPage => _startPage;

  set startPage(String startPage) {
    _startPage = startPage;
    userPrefsBox.put('startPage', startPage);
    notifyListeners();
  }

  bool _darkModeEnabled = false;

  bool get darkModeEnabled => _darkModeEnabled;

  set darkModeEnabled(bool darkModeEnabled) {
    _darkModeEnabled = darkModeEnabled;
    userPrefsBox.put('darkModeEnabled', darkModeEnabled);
    notifyListeners();
  }
}
