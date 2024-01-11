import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../json/image.dart';

class ImageModel extends ChangeNotifier {
  final imageBox = Hive.box('imageBox');

  List<ImageObject> get images => _images;

  final List<ImageObject> _images = [];

  void addImage(ImageObject image) {
    _images.add(image);
    imageBox.add(image);
    notifyListeners();
  }
}
