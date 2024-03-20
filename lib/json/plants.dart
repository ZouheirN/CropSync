// To parse this JSON data, do
//
//     final plants = plantsFromJson(jsonString);

import 'dart:convert';

Plants plantsFromJson(Map<String, dynamic> json) => Plants.fromJson(json);

String plantsToJson(Plants data) => json.encode(data.toJson());

class Plants {
  List<PlantsDatum>? data;

  Plants({
    this.data,
  });

  factory Plants.fromJson(Map<String, dynamic> json) => Plants(
    data: json["data"] == null ? [] : List<PlantsDatum>.from(json["data"]!.map((x) => PlantsDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class PlantsDatum {
  String? commonName;
  String? imageUrl;
  String? scientificName;

  PlantsDatum({
    this.commonName,
    this.imageUrl,
    this.scientificName,
  });

  factory PlantsDatum.fromJson(Map<String, dynamic> json) => PlantsDatum(
    commonName: json["common_name"],
    imageUrl: json["image_url"],
    scientificName: json["scientific_name"],
  );

  Map<String, dynamic> toJson() => {
    "common_name": commonName,
    "image_url": imageUrl,
    "scientific_name": scientificName,
  };
}
