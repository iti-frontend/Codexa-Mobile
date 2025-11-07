import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiManager {
  late Dio dio;
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? "";

  ApiManager() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  // GET Request
  Future<Response> getData(String endPoint,
      {Map<String, dynamic>? query}) async {
    try {
      final response = await dio.get(endPoint, queryParameters: query);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST Request
  Future<Response> postData(String endPoint,
      {Map<String, dynamic>? body}) async {
    try {
      final response = await dio.post(
        endPoint,
        data: body,
        options: Options(validateStatus: (status) => true),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}