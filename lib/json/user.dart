import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject{
  @HiveField(0)
  String fullName;
  @HiveField(1)
  String email;
  @HiveField(2)
  List<String> microId;
  @HiveField(3)
  bool isVerified;

  User({
    required this.fullName,
    required this.email,
    required this.microId,
    required this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var microIdFromJson = json['microId'];
    List<String> microIdList = microIdFromJson.cast<String>();

    return User(
      fullName: json['fullName'],
      email: json['email'],
      microId: microIdList,
      isVerified: json['isVerified'],
    );
  }
}
