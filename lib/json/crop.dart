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
  Alerts? alerts;

  Crop({
    this.name,
    this.profile,
    this.alerts,
  });

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
        name: json["name"],
        profile: json["profile"],
        alerts: json["alerts"] == null ? null : Alerts.fromJson(json["alerts"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "profile": profile,
        "alerts": alerts?.toJson(),
      };
}

@HiveType(typeId: 4)
class Alerts {
  @HiveField(0)
  Soil? soil;
  @HiveField(1)
  Leaf? leaf;

  Alerts({
    this.soil,
    this.leaf,
  });

  factory Alerts.fromJson(Map<String, dynamic> json) => Alerts(
    soil: json["soil"] == null ? null : Soil.fromJson(json["soil"]),
    leaf: json["leaf"] == null ? null : Leaf.fromJson(json["leaf"]),
  );

  Map<String, dynamic> toJson() => {
    "soil": soil?.toJson(),
    "leaf": leaf?.toJson(),
  };
}

@HiveType(typeId: 5)
class Leaf {
  @HiveField(0)
  List<String>? message;
  @HiveField(1)
  List<String>? action;
  @HiveField(2)
  String? status;

  Leaf({
    this.message,
    this.action,
    this.status,
  });

  factory Leaf.fromJson(Map<String, dynamic> json) => Leaf(
    message: json["message"] == null ? [] : List<String>.from(json["message"]!.map((x) => x)),
    action: json["action"] == null ? [] : List<String>.from(json["action"]!.map((x) => x)),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "message": message == null ? [] : List<dynamic>.from(message!.map((x) => x)),
    "action": action == null ? [] : List<dynamic>.from(action!.map((x) => x)),
    "status": status,
  };
}

@HiveType(typeId: 6)
class Soil {
  @HiveField(0)
  List<String>? nutrient;
  @HiveField(1)
  List<String>? severity;
  @HiveField(2)
  List<String>? message;
  @HiveField(3)
  List<String>? action;

  Soil({
    this.nutrient,
    this.severity,
    this.message,
    this.action,
  });

  factory Soil.fromJson(Map<String, dynamic> json) => Soil(
    nutrient: json["nutrient"] == null ? [] : List<String>.from(json["nutrient"]!.map((x) => x)),
    severity: json["severity"] == null ? [] : List<String>.from(json["severity"]!.map((x) => x)),
    message: json["message"] == null ? [] : List<String>.from(json["message"]!.map((x) => x)),
    action: json["action"] == null ? [] : List<String>.from(json["action"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "nutrient": nutrient == null ? [] : List<dynamic>.from(nutrient!.map((x) => x)),
    "severity": severity == null ? [] : List<dynamic>.from(severity!.map((x) => x)),
    "message": message == null ? [] : List<dynamic>.from(message!.map((x) => x)),
    "action": action == null ? [] : List<dynamic>.from(action!.map((x) => x)),
  };
}
