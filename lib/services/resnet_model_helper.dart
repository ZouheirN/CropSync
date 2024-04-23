import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cropsync/json/image.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/models/image_model.dart';
import 'package:cropsync/services/disease_api.dart';
import 'package:cropsync/utils/other_variables.dart';
import 'package:cropsync/widgets/dialogs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:watch_it/watch_it.dart';

class ResNetModelHelper {
  Interpreter? interpreter;

  List<String> classLabels = [
    'Bacterial Spot',
    'Early Blight',
    'Healthy',
    'Late Blight',
    'Powdery Mildew'
  ];

  Future<void> predict({
    required base64image,
    required int index,
  }) async {
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

    var input = preprocessInput(base64image);

    var output = List.filled(1 * 5, 0).reshape([1, 5]);

    await Future.delayed(
        const Duration(seconds: 1)); // bug from package, this is the fix
    await isolateInterpreter.run(input, output);

    // Extracting the inner list from the output
    List<double> innerList = output[0];

    // Find the index of the maximum value in the inner list
    int maxIndex = 0;
    double maxValue = innerList[0];
    for (int i = 1; i < innerList.length; i++) {
      if (innerList[i] > maxValue) {
        maxValue = innerList[i];
        maxIndex = i;
      }
    }

    // Retrieve the corresponding class label
    String predictedClassLabel = classLabels[maxIndex];

    logger.i("$output\nPredicted class: $predictedClassLabel");

    interpreter?.close();
    isolateInterpreter.close();

    final results = {
      'prediction': predictedClassLabel,
      'confidence': output[0][maxIndex] * 100,
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

  List preprocessInput(String base64Image) {
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

    // print first pixels
    logger.i(input[0][0]);

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

    // print first pixels
    logger.i("First Pixels after normalization: ${input[0][0]}");

    // return as [1, 224, 224, 3]
    return input.reshape([1, 224, 224, 3]);
  }

  double truncateToDecimalPlaces(num value, int fractionalDigits) =>
      (value * pow(10, fractionalDigits)).truncate() /
      pow(10, fractionalDigits);

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

  void pickImage(ImageSource source, {required bool isLocal}) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;

    File? img = File(image.path);
    img = await cropImage(imageFile: img);

    if (img == null) return;

    di<ImageModel>().addImage(ImageObject(
      image: img.readAsBytesSync(),
      result: '',
      uploadProgress: 0,
      info: '',
    ));

    if (!isLocal) {
      DiseaseApi.getDiseaseDataFromGemeni(
        img.readAsBytesSync(),
        di<ImageModel>().images.length - 1,
      );
    } else {
      final base64Image = base64Encode(img.readAsBytesSync());
      ResNetModelHelper().predict(
        base64image: base64Image,
        index: di<ImageModel>().images.length - 1,
      );
    }
  }

  Future<File?> cropImage({required File imageFile}) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: const [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: MyApp.themeNotifier.value == ThemeMode.light
              ? Colors.white
              : const Color(0xFF191C1B),
          toolbarWidgetColor: MyApp.themeNotifier.value == ThemeMode.light
              ? Colors.black
              : Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          rotateButtonsHidden: true,
          rotateClockwiseButtonHidden: true,
          aspectRatioLockEnabled: false,
        ),
      ],
    );
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }
}
