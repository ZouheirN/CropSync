import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'image.g.dart';

@HiveType(typeId: 0)
class ImageObject extends HiveObject {
  @HiveField(1)
  Uint8List image;
  @HiveField(2)
  String? result;

  ImageObject({
    required this.image,
    required this.result,
  });
}
