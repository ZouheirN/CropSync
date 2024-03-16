import 'package:cropsync/json/plants.dart';
import 'package:cropsync/main.dart';
import 'package:cropsync/utils/api_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TrefleApi {
  static final dio = Dio();

  static final apiKey = dotenv.env['TREFLE_API_KEY'];

  static Future<dynamic> getPlants(int page) async {
    try {
      final response = await dio.get(
        'https://trefle.io/api/v1/plants',
        data: {
          'token': apiKey,
          'page': page,
          'filter_not': {
            'common_name': "null",
          }
        },
      );

      final plants = plantsFromJson(response.data);

      return plants.data;
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      logger.e(e.response?.data);

      return ReturnTypes.fail;
    }
  }

  static Future<dynamic> searchPlants(String query, int page) async {
    try {
      final response = await dio.get(
        'https://trefle.io/api/v1/plants/search',
        data: {
          'token': apiKey,
          'q': query,
          'page': page,
          'filter_not': {
            'common_name': "null",
          }
        },
      );

      final plants = plantsFromJson(response.data);

      return plants.data;
    } on DioException catch (e) {
      if (e.response == null) return ReturnTypes.error;

      if (e.response?.statusCode == 404) {
        return ReturnTypes.endOfPages;
      }

      logger.e(e.response?.data);

      return ReturnTypes.fail;
    }
  }
}
