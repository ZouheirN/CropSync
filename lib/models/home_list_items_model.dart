import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomeListItemsModel extends ChangeNotifier {
  final userPrefsBox = Hive.box('userPrefs');

  List<String> _homeListItems = [];

  List<String> get listItems => _homeListItems;

  set homeListItems(List<String> homeListItems) {
    _homeListItems = homeListItems;
    userPrefsBox.put('homeListItems', homeListItems);
    notifyListeners();
  }
}
