
import 'package:hive/hive.dart';

part 'crop.g.dart';

@HiveType(typeId: 3)
class Crop {
  @HiveField(0)
  String? name;

  Crop({
    this.name,
  });

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
  };
}