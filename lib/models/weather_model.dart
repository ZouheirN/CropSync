import 'package:cropsync/json/weather.dart';
import 'package:flutter/material.dart';

class WeatherModel extends ChangeNotifier {
  List<Weather> get weather => _weather;

  List<Weather> _weather = [];

  set weather(List<Weather> weather) {
    _weather = weather;
    notifyListeners();
  }
}
