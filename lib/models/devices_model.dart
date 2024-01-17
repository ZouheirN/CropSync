import 'package:cropsync/json/devices.dart';
import 'package:flutter/material.dart';

class DevicesModel extends ChangeNotifier {
  List<Devices> get devices => _devices;

  final List<Devices> _devices = [];

  void addDevice(int id, String name, String code) {
    _devices
        .add(Devices(id: id, crop: Crop(name: null), name: name, code: code));
    notifyListeners();
  }

  void deleteDevice(int id) {
    _devices.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}
