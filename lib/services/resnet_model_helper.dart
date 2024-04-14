import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cropsync/main.dart';
import 'package:cropsync/utils/other_variables.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:watch_it/watch_it.dart';

class ResnetModelHelper {
  Interpreter? interpreter;

  Future<Map<String, dynamic>> predict(base64image) async {
    final InterpreterOptions options = InterpreterOptions();
    options.threads = 4;

    try {
      final dataFile = File(di<OtherVars>().resNetFilePath);
      interpreter = Interpreter.fromFile(dataFile, options: options);
    } catch (e) {
      di<OtherVars>().resNetFilePath = '';

      return {
        'prediction': 'Error loading model',
        'confidence': 0,
      };
    }

    var input = base64ImageToTensor(base64image);

    var output = List.filled(1 * 2, 0).reshape([1, 2]);

    List<String> classLabels = ['diseased', 'healthy'];

    interpreter!.run(input, output);

    // Get the predicted class index
    int predictedClassIndex = output[0][0] > output[0][1] ? 0 : 1;

    // Get the predicted class label
    String predictedClassLabel = classLabels[predictedClassIndex];

    logger.i("$output\nPredicted class: $predictedClassLabel");

    interpreter?.close();

    return {
      'prediction': predictedClassLabel,
      'confidence': output[0][predictedClassIndex] * 100,
    };
  }

  List<List<List<List<double>>>> base64ImageToTensor(String base64Image) {
    // Decode the base64 string into bytes
    Uint8List imageBytes = base64.decode(base64Image);

    // Convert the bytes into an image
    img.Image? image = img.decodeImage(imageBytes);

    // Resize the image to match the input size required by the model
    img.Image resizedImage = img.copyResize(image!, width: 224, height: 224);

    // Caffe preprocessing: mean subtraction
    // Precomputed mean values for RGB channels
    double meanRed = 123.68;
    double meanGreen = 116.779;
    double meanBlue = 103.939;

    // Normalize pixel values and convert to float32
    List<List<List<double>>> normalizedImage = List.generate(224, (y) {
      return List.generate(224, (x) {
        // Get pixel values
        img.Pixel pixel = resizedImage.getPixel(x, y);
        // Extract RGB channels, normalize, and subtract mean
        double red = (pixel.r - meanRed) / 255;
        double green = (pixel.g - meanGreen) / 255;
        double blue = (pixel.b - meanBlue) / 255;
        return [red, green, blue];
      });
    });

    // Expand dimensions to match the expected input shape [1, 224, 224, 3]
    List<List<List<List<double>>>> tensor = [normalizedImage];

    return tensor;
  }

  void loadModel(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      // allowedExtensions: ['tflite'],
      type: FileType.any,
      dialogTitle: 'Select the ResNet model file',
    );

    if (result == null) return;

    final file = result.files.first;

    // check if file extension is tflite
    if (!file.name.endsWith('.tflite')) {
      if (!context.mounted) return;
      Dialogs.showErrorDialog(
          'Invalid file format', 'Please select a .tflite file', context);
      return;
    }

    di<OtherVars>().resNetFilePath = file.path!;

    if (!context.mounted) return;
    Dialogs.showSuccessDialog('Success', 'Model loaded successfully', context);
  }
}
