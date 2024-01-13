import 'package:hive/hive.dart';
import 'dart:convert';

part 'device_camera.g.dart';

List<DeviceCamera> deviceCameraFromJson(List<dynamic> json) =>
    List<DeviceCamera>.from(json.map((x) => DeviceCamera.fromJson(x)));


String deviceCameraToJson(List<DeviceCamera> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 5)
class DeviceCamera {
  @HiveField(0)
  int? deviceId;
  @HiveField(1)
  String? deviceName;
  @HiveField(2)
  String? location;
  @HiveField(3)
  String? image;

  DeviceCamera({
    this.deviceId,
    this.deviceName,
    this.location,
    this.image,
  });

  DeviceCamera.fromJson(Map<String, dynamic> json) {
    deviceId = json['deviceId'];
    deviceName = json['deviceName'];
    location = json['location'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceId'] = deviceId;
    data['deviceName'] = deviceName;
    data['location'] = location;
    data['image'] = image;
    return data;
  }
}
