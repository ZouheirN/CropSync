import 'package:cropsync/json/crop.dart';
import 'package:cropsync/json/device.dart';
import 'package:flutter/material.dart';

class DevicesModel extends ChangeNotifier {
  List<Device> get devices => _devices;

  final List<Device> _devices = [];

  set devices(List<Device> devices) {
    _devices.clear();
    _devices.addAll(devices);
    notifyListeners();
  }

  void addDevice({
    required String id,
    required String name,
    required bool isConnected,
    required String location,
    required String code,
  }) {
    _devices.add(
      Device(
        deviceId: id,
        crop: Crop(name: null),
        name: name,
        isConnected: isConnected,
        location: location,
        code: code,
      ),
    );
    notifyListeners();
  }

  void deleteDevice(String id) {
    _devices.removeWhere((element) => element.deviceId == id);
    notifyListeners();
  }
}
