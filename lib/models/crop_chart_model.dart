import 'package:cropsync/json/crop_chart.dart';
import 'package:flutter/material.dart';

class CropChartModel extends ChangeNotifier {
  CropChart get cropCharts => _cropCharts;

  CropChart _cropCharts = CropChart();

  set cropCharts(CropChart cropCharts) {
    _cropCharts = cropCharts;
    notifyListeners();
  }
}
