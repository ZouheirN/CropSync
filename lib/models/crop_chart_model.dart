import 'package:cropsync/json/crop_chart.dart';
import 'package:flutter/material.dart';

class CropChartModel extends ChangeNotifier {
  CropChart get weeklyCropCharts => _weeklyCropCharts;

  CropChart _weeklyCropCharts = CropChart();

  set weeklyCropCharts(CropChart weeklyCropCharts) {
    _weeklyCropCharts = weeklyCropCharts;
    notifyListeners();
  }

  CropChart get monthlyCropCharts => _monthlyCropCharts;

  CropChart _monthlyCropCharts = CropChart();

  set monthlyCropCharts(CropChart monthlyCropCharts) {
    _monthlyCropCharts = monthlyCropCharts;
    notifyListeners();
  }
}
