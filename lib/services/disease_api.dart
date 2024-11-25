import 'dart:convert';

import 'package:cropsync/models/image_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:watch_it/watch_it.dart';

class DiseaseApi {
  static final dio = Dio();

  static final apiUrl = dotenv.env['API_URL'];

  static Future getDiseaseDataFromGemini(
      Uint8List imageBytes, int index) async {
    di<ImageModel>().setResult(index, 'Processing...');

    final model = GenerativeModel(
        model: 'gemini-pro-vision',
        apiKey: dotenv.env['GOOGLE_GENERATIVE_AI_API_KEY']!);
    const prompt = '''
    Analyze the image and provide a description of the disease.
    Return the data as json, like this:
    {
      "disease": "Rust", (should be brief and short)
      "info": (any additional information)   
    }
    If the image is not a plant leaf, return "Not a leaf".
         ''';
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/png', imageBytes),
      ])
    ];

    final response = await model.generateContent(content);

    if (response.text == null) {
      di<ImageModel>().setResult(index, 'No Result');
      di<ImageModel>().setInfo(index, '');
      return;
    } else if (response.text == 'Not a leaf') {
      di<ImageModel>().setResult(index, 'Not a leaf');
      di<ImageModel>().setInfo(index, '');
      return;
    }

    // parse the response and set the result
    final result = jsonDecode(response.text!);

    di<ImageModel>().setResult(index, result['disease']);
    di<ImageModel>().setInfo(index, result['info']);
  }
}
