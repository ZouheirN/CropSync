
import 'dart:convert';


List<DeviceCamera> deviceCameraFromJson(List<dynamic> json) =>
    List<DeviceCamera>.from(json.map((x) => DeviceCamera.fromJson(x)));


String deviceCameraToJson(List<DeviceCamera> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DeviceCamera {
  int? deviceId;
  String? deviceName;
  String? location;
  String? cropName;
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
    cropName = json['cropName'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deviceId'] = deviceId;
    data['deviceName'] = deviceName;
    data['location'] = location;
    data['cropName'] = cropName;
    data['image'] = image;
    return data;
  }
}
