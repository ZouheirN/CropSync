import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

User userFromJson(Map<String, dynamic> json) => User.fromJson(json);

String userToJson(User data) => json.encode(data.toJson());

@HiveType(typeId: 1)
class User {
  @HiveField(1)
  String? token;
  @HiveField(2)
  Uint8List? profilePicture;
  @HiveField(3)
  double? uploadProgress;
  @HiveField(4)
  String? fullName;
  @HiveField(5)
  String? email;
  @HiveField(6)
  bool? isVerified;
  @HiveField(7)
  String? externalId;

  User({
    this.token,
    this.profilePicture,
    this.uploadProgress,
    this.fullName,
    this.email,
    this.isVerified,
    this.externalId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        token: json["token"],
        profilePicture: json["profilePicture"] != null
            ? base64Decode(json["profilePicture"])
            : null,
        uploadProgress: json["profilePicture"] != null ? 1 : null,
        fullName: json["fullName"],
        email: json["email"],
        isVerified: json["isVerified"],
    externalId: json["externalId"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "profilePicture": profilePicture,
        "fullName": fullName,
        "email": email,
        "isVerified": isVerified,
        "externalId": externalId,
      };
}
