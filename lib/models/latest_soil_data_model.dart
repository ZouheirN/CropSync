import 'package:cropsync/json/soil_data.dart';
import 'package:flutter/material.dart';

class LatestSoilDataModel extends ChangeNotifier {
  List<Map<String, SoilData>> get soilData => _soilData;

  final List<Map<String, SoilData>> _soilData = [];

  void setSoilData(SoilData soilData) {
    // check if the device id is already in the list
    if (_soilData.isNotEmpty) {
      final index = _soilData.indexWhere((element) =>
          element.values.first.deviceId == soilData.deviceId);
      if (index != -1) {
        _soilData[index] = {soilData.deviceId!: soilData};
      } else {
        _soilData.add({soilData.deviceId!: soilData});
      }
    } else {
      _soilData.add({soilData.deviceId!: soilData});
    }
    notifyListeners();
  }
}
