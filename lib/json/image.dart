import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'image.g.dart';

@HiveType(typeId: 1)
class ImageObject extends HiveObject {
  @HiveField(0)
  Uint8List image;
  @HiveField(1)
  String? result;

  ImageObject({
    required this.image,
    required this.result,
  });
}
