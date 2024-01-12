import 'package:hive/hive.dart';
import 'dart:convert';

part 'user.g.dart';

User userFromJson(Map<String, dynamic> json) => User.fromJson(json);

String userToJson(User data) => json.encode(data.toJson());

@HiveType(typeId: 1)
class User {
  @HiveField(0)
  String? token;
  @HiveField(1)
  String? fullName;
  @HiveField(2)
  String? email;
  @HiveField(3)
  bool? isVerified;
  @HiveField(4)
  List<Devices>? devices;

  User({this.token, this.fullName, this.email, this.isVerified, this.devices});

  User.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    fullName = json['fullName'];
    email = json['email'];
    isVerified = json['isVerified'];
    if (json['devices'] != null) {
      devices = <Devices>[];
      json['devices'].forEach((v) {
        devices!.add(Devices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['fullName'] = fullName;
    data['email'] = email;
    data['isVerified'] = isVerified;
    if (devices != null) {
      data['devices'] = devices!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@HiveType(typeId: 2)
class Devices {
  @HiveField(0)
  int? id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  Crop? crop;

  Devices({this.id, this.name, this.crop});

  Devices.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    crop = json['crop'] != null ? Crop.fromJson(json['crop']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (crop != null) {
      data['crop'] = crop!.toJson();
    }
    return data;
  }
}

@HiveType(typeId: 3)
class Crop {
  @HiveField(0)
  String? name;

  Crop({this.name});

  Crop.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    return data;
  }
}
