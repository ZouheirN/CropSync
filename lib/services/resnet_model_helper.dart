import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cropsync/main.dart';
import 'package:cropsync/models/image_model.dart';
import 'package:cropsync/utils/other_variables.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:watch_it/watch_it.dart';

class ResnetModelHelper {
  Interpreter? interpreter;

  Future<void> predict(base64image, int index) async {
    di<ImageModel>().setResult(
      index,
      'Predicting...',
    );
    di<ImageModel>().setInfo(
      index,
      '',
    );

    final InterpreterOptions options = InterpreterOptions();
    options.threads = 4;

    IsolateInterpreter? isolateInterpreter;

    try {
      final dataFile = File(di<OtherVars>().resNetFilePath);
      interpreter = Interpreter.fromFile(dataFile, options: options);
    } catch (e) {
      di<OtherVars>().resNetFilePath = '';

      di<ImageModel>().setResult(
        index,
        'Error loading model',
      );
      di<ImageModel>().setInfo(
        index,
        '',
      );
      return;
    }

    isolateInterpreter =
        await IsolateInterpreter.create(address: interpreter!.address);

    // var input = base64ImageToTensor(base64image);
    var input = preprocessInput(base64image);

    var output = List.filled(1 * 2, 0).reshape([1, 2]);

    List<String> classLabels = ['diseased', 'healthy'];

    await Future.delayed(
        const Duration(seconds: 1)); // bug from package, this is the fix
    await isolateInterpreter.run(input, output);

    // Get the predicted class index
    int predictedClassIndex = output[0][0] > output[0][1] ? 0 : 1;

    // Get the predicted class label
    String predictedClassLabel = classLabels[predictedClassIndex];

    logger.i("$output\nPredicted class: $predictedClassLabel");

    interpreter?.close();
    isolateInterpreter.close();

    final results = {
      'prediction': predictedClassLabel,
      'confidence': output[0][predictedClassIndex] * 100,
    };

    di<ImageModel>().setResult(
      index,
      results['prediction'],
    );
    di<ImageModel>().setInfo(
      index,
      'Confidence: ${truncateToDecimalPlaces(results['confidence'], 2)}%',
    );
  }

  List<List<List<List<double>>>> preprocessInput(String base64Image) {
    img.Image image = img.decodeImage(base64.decode(base64Image))!;

    image = img.copyResize(
      image,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.average,
    );

    // convert without normalization
    List<List<List<double>>> input = List.generate(224, (y) {
      return List.generate(224, (x) {
        img.Pixel pixel = image.getPixel(x, y);
        return [
          pixel.r.toDouble(),
          pixel.g.toDouble(),
          pixel.b.toDouble(),
        ];
      });
    });

    // convert rgb to bgr
    for (var i = 0; i < input.length; i++) {
      for (var j = 0; j < input[i].length; j++) {
        var temp = input[i][j][0];
        input[i][j][0] = input[i][j][2];
        input[i][j][2] = temp;
      }
    }

    // Zero-center by mean pixel
    List<double> mean = [103.939, 116.779, 123.68];
    for (var i = 0; i < input.length; i++) {
      for (var j = 0; j < input[i].length; j++) {
        for (var k = 0; k < input[i][j].length; k++) {
          input[i][j][k] -= mean[k];
        }
      }
    }

    return [input];
  }

  // List<List<List<List<double>>>> base64ImageToTensor(String base64Image) {
  //   // Decode the base64 string into bytes
  //   Uint8List imageBytes = base64.decode(base64Image);
  //
  //   // Convert the bytes into an image
  //   img.Image? image = img.decodeImage(imageBytes);
  //
  //   // Resize the image to match the input size required by the model
  //   img.Image resizedImage = img.copyResize(image!, width: 224, height: 224);
  //
  //   // Caffe preprocessing: mean subtraction
  //   // Precomputed mean values for RGB channels
  //   double meanRed = 123.68;
  //   double meanGreen = 116.779;
  //   double meanBlue = 103.939;
  //
  //   // Normalize pixel values and convert to float32
  //   List<List<List<double>>> normalizedImage = List.generate(224, (y) {
  //     return List.generate(224, (x) {
  //       // Get pixel values
  //       img.Pixel pixel = resizedImage.getPixel(x, y);
  //       // Extract RGB channels, normalize, and subtract mean
  //       double red = (pixel.r - meanRed) / 255;
  //       double green = (pixel.g - meanGreen) / 255;
  //       double blue = (pixel.b - meanBlue) / 255;
  //       return [red, green, blue];
  //     });
  //   });
  //
  //   // Expand dimensions to match the expected input shape [1, 224, 224, 3]
  //   List<List<List<List<double>>>> tensor = [normalizedImage];
  //
  //   return tensor;
  // }

  double truncateToDecimalPlaces(num value, int fractionalDigits) => (value * pow(10,
      fractionalDigits)).truncate() / pow(10, fractionalDigits);

  void loadModel(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();

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
