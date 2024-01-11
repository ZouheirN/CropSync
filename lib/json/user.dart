import 'package:hive/hive.dart';
import 'dart:convert';

part 'user.g.dart';

User userFromJson(Map<String,dynamic> json) => User.fromJson(json);

String userToJson(User data) => json.encode(data.toJson());

@HiveType(typeId: 1)
class User {
  @HiveField(1)
  String token;
  @HiveField(2)
  String fullName;
  @HiveField(3)
  String email;
  @HiveField(4)
  bool isVerified;
  @HiveField(5)
  List<Device> devices;

  User({
    required this.token,
    required this.fullName,
    required this.email,
    required this.isVerified,
    required this.devices,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    token: json["token"],
    fullName: json["fullName"],
    email: json["email"],
    isVerified: json["isVerified"],
    devices: List<Device>.from(json["devices"].map((x) => Device.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "fullName": fullName,
    "email": email,
    "isVerified": isVerified,
    "devices": List<dynamic>.from(devices.map((x) => x.toJson())),
  };
}

@HiveType(typeId: 2)
class Device {
  @HiveField(1)
  int id;
  @HiveField(2)
  String name;
  @HiveField(3)
  Crop crop;

  Device({
    required this.id,
    required this.name,
    required this.crop,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    id: json["id"],
    name: json["name"],
    crop: Crop.fromJson(json["crop"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "crop": crop.toJson(),
  };
}

@HiveType(typeId: 3)
class Crop {
  @HiveField(1)
  String name;

  Crop({
    required this.name,
  });

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
  };
}
