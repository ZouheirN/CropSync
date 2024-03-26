// To parse this JSON data, do
//
//     final deviceCameraHistory = deviceCameraHistoryFromJson(jsonString);

import 'dart:convert';

DeviceCameraHistory deviceCameraHistoryFromJson(Map<String, dynamic> json) => DeviceCameraHistory.fromJson(json);

String deviceCameraHistoryToJson(DeviceCameraHistory data) => json.encode(data.toJson());

class DeviceCameraHistory {
  List<String>? images;
  List<DateTime>? cameraCollectionDate;
  Pagination? pagination;

  DeviceCameraHistory({
    this.images,
    this.cameraCollectionDate,
    this.pagination,
  });

  factory DeviceCameraHistory.fromJson(Map<String, dynamic> json) => DeviceCameraHistory(
    images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
    cameraCollectionDate: json["cameraCollectionDate"] == null ? [] : List<DateTime>.from(json["cameraCollectionDate"]!.map((x) => DateTime.parse(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
    "cameraCollectionDate": cameraCollectionDate == null ? [] : List<dynamic>.from(cameraCollectionDate!.map((x) => x.toIso8601String())),
    "pagination": pagination?.toJson(),
  };
}

class Pagination {
  int? totalImages;
  int? currentPage;
  int? totalPages;

  Pagination({
    this.totalImages,
    this.currentPage,
    this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    totalImages: json["totalImages"],
    currentPage: json["currentPage"],
    totalPages: json["totalPages"],
  );

  Map<String, dynamic> toJson() => {
    "totalImages": totalImages,
    "currentPage": currentPage,
    "totalPages": totalPages,
  };
}
