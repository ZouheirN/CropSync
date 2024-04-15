import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

    var input = base64ImageToTensor(base64image);

    logger.d(input[0][5][0]);

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
      'Confidence: ${results['confidence'].toStringAsFixed(2)}%',
    );
  }

  List<List<List<List<double>>>> preprocessInput(String base64Image) {
    // Decode base64 image string
    Uint8List decodedBytes = base64.decode(base64Image);

    // Decode the image using Dart image package
    img.Image image = img.decodeImage(decodedBytes)!;

    // Resize image to 224x224
    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

    // Convert the resized image to a numpy array
    List<List<List<double>>> numpyArray = [];
    for (int y = 0; y < resizedImage.height; y++) {
      List<List<double>> row = [];
      for (int x = 0; x < resizedImage.width; x++) {
        img.Pixel pixel = resizedImage.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();
        row.add([r.toDouble(), g.toDouble(), b.toDouble()]);
      }
      numpyArray.add(row);
    }

    // 'RGB'->'BGR'
    for (var i = 0; i < numpyArray.length; i++) {
      for (var j = 0; j < numpyArray[i].length; j++) {
        numpyArray[i][j].insert(0, numpyArray[i][j].removeAt(2));
      }
    }

    // Mean and std deviation
    List<double> mean = [103.939, 116.779, 123.68];

    // Zero-center by mean pixel
    for (var i = 0; i < numpyArray.length; i++) {
      for (var j = 0; j < numpyArray[i].length; j++) {
        for (var k = 0; k < numpyArray[i][j].length; k++) {
          numpyArray[i][j][k] -= mean[k];
        }
      }
    }

    // Add an extra dimension to match the (1, 224, 224, 3) shape
    List<List<List<List<double>>>> result = [numpyArray];

    return result;
  }

  // Float32List preprocessInput(Float32List imgArray) {
  //   // 'RGB'->'BGR'
  //   Float32List imgArrayBGR = Float32List(imgArray.length);
  //   for (int i = 0; i < imgArray.length; i += 3) {
  //     imgArrayBGR[i] = imgArray[i + 2];
  //     imgArrayBGR[i + 1] = imgArray[i + 1];
  //     imgArrayBGR[i + 2] = imgArray[i];
  //   }
  //   // Zero-center by mean pixel
  //   double meanR = 103.939;
  //   double meanG = 116.779;
  //   double meanB = 123.68;
  //   for (int i = 0; i < imgArrayBGR.length; i += 3) {
  //     imgArrayBGR[i] -= meanR;
  //     imgArrayBGR[i + 1] -= meanG;
  //     imgArrayBGR[i + 2] -= meanB;
  //   }
  //   return imgArrayBGR;
  // }

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
