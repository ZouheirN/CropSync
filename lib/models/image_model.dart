import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../json/image.dart';

class ImageModel extends ChangeNotifier {
  final imagesBox = Hive.box('images');

  List<ImageObject> get images => _images;

  final List<ImageObject> _images = [];

  void addImage(ImageObject image) {
    _images.add(image);
    imagesBox.add(image);
    notifyListeners();
  }

  void deleteImage(int index) {
    _images.removeAt(index);
    imagesBox.deleteAt(index);
    notifyListeners();
  }

  void setProgress(int index, double progress) {
    _images[index].uploadProgress = progress;
    notifyListeners();
  }

  void setResult(int index, String result) {
    _images[index].result = result;
    notifyListeners();
  }
}
