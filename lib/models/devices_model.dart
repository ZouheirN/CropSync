import 'package:cropsync/json/crop.dart';
import 'package:cropsync/json/device.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DevicesModel extends ChangeNotifier {
  final devicesBox = Hive.box('devices');

  List<Device> get devices => _devices;

  final List<Device> _devices = [];

  set devices(List<Device> devices) {
    _devices.clear();
    _devices.addAll(devices);
    devicesBox.put('devices', _devices);
    notifyListeners();
  }

  void addDevice({
    required String id,
    required String name,
    required bool isConnected,
    required String location,
    required String code,
    required Crop crop,
  }) {
    _devices.add(
      Device(
        deviceId: id,
        crop: crop,
        name: name,
        isConnected: isConnected,
        location: location,
        code: code,
      ),
    );
    devicesBox.put('devices', _devices);
    notifyListeners();
  }

  void editDevice({
    required String id,
    required String name,
    required String location,
  }) {
    final index = _devices.indexWhere((element) => element.deviceId == id);
    final isConnected = _devices[index].isConnected;
    final code = _devices[index].code;
    final crop = _devices[index].crop;
    _devices[index] = Device(
      deviceId: id,
      crop: crop,
      name: name,
      isConnected: isConnected,
      location: location,
      code: code,
    );
    devicesBox.put('devices', _devices);
    notifyListeners();
  }

  void setCrop({required String id, required String name, required String profile}) {
    final index = _devices.indexWhere((element) => element.deviceId == id);
    _devices[index].crop = Crop(
      name: name,
      profile: profile,
    );
    devicesBox.put('devices', _devices);
    notifyListeners();
  }

  void deleteDevice(String id) {
    _devices.removeWhere((element) => element.deviceId == id);
    devicesBox.put('devices', _devices);
    notifyListeners();
  }
}
