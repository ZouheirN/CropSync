import 'dart:convert';

import 'package:hive/hive.dart';

part 'crop.g.dart';

Crop cropFromJson(String str) => Crop.fromJson(json.decode(str));

String cropToJson(Crop data) => json.encode(data.toJson());

@HiveType(typeId: 3)
class Crop {
  @HiveField(0)
  String? name;
  @HiveField(1)
  String? profile;
  @HiveField(2)
  String? status;

  Crop({
    this.name,
    this.profile,
    this.status,
  });

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
        name: json["name"],
        profile: json["profile"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "profile": profile,
        "status": status,
      };
}
