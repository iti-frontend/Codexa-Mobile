import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiManager {
  late Dio dio;
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? "";

  final SharedPreferences prefs;

  ApiManager({required this.prefs}) {
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
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Read token dynamically from SharedPreferences
          final token = prefs.getString('token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
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

  // PUT Request
  Future<Response> putData(String endPoint,
      {Map<String, dynamic>? body}) async {
    try {
      final response = await dio.put(
        endPoint,
        data: body,
        options: Options(validateStatus: (status) => true),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE Request
  Future<Response> deleteData(String endPoint,
      {Map<String, dynamic>? body}) async {
    try {
      final response = await dio.delete(
        endPoint,
        data: body,
        options: Options(validateStatus: (status) => true),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> uploadData(String endPoint, List<File> files,
      {String fieldName = 'files'}) async {
    try {
      final formData = FormData();
      for (final file in files) {
        formData.files.add(
          MapEntry(
            fieldName,
            await MultipartFile.fromFile(file.path,
                filename: file.path.split('/').last),
          ),
        );
      }

      final response = await dio.post(
        endPoint,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          validateStatus: (status) => true,
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
