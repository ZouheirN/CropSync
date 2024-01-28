import 'package:cropsync/models/image_model.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:watch_it/watch_it.dart';

class DiseaseApi {
  static final dio = Dio();

  static final apiUrl = dotenv.env['API_URL'];

  static Future<dynamic> uploadDiseaseImage({
    required String image,
    required int index,
  }) async {
    di<ImageModel>().setResult(index, 'Uploading...');

    try {
      await dio.post(
        'https://httpbin.org/post',
        data: {
          'image': image,
        },
        onSendProgress: (int sent, int total) {
          di<ImageModel>().setProgress(index, sent / total);

          if (sent == total) {
            di<ImageModel>().setResult(index, 'Processing...');
          }
        },
      );
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      Logger().e(e.response?.data);
      di<ImageModel>().setResult(index, 'Upload Failed');
    }
  }
}