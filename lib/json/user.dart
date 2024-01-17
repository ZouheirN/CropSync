import 'package:hive/hive.dart';
import 'dart:convert';

part 'user.g.dart';

User userFromJson(Map<String,dynamic> json) => User.fromJson(json);

String userToJson(User data) => json.encode(data.toJson());

@HiveType(typeId: 1)
class User {
  @HiveField(1)
  String? token;
  @HiveField(2)
  String? fullName;
  @HiveField(3)
  String? email;
  @HiveField(4)
  bool? isVerified;

  User({
    this.token,
    this.fullName,
    this.email,
    this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    token: json["token"],
    fullName: json["fullName"],
    email: json["email"],
    isVerified: json["isVerified"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "fullName": fullName,
    "email": email,
    "isVerified": isVerified,
  };
}
