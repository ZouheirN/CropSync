import 'package:cropsync/json/device_camera.dart';
import 'package:flutter/material.dart';

class DeviceCameraModel extends ChangeNotifier {
  List<DeviceCamera> get deviceCamera => _deviceCamera;

  List<DeviceCamera> _deviceCamera = [];

  set deviceCamera(List<DeviceCamera> deviceCamera) {
    _deviceCamera = deviceCamera;
    notifyListeners();
  }
}
