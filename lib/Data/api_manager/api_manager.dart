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

  // POST Request with Multipart (files + fields)
  Future<Response> postMultipartData(
    String endPoint, {
    File? file,
    String fileFieldName = 'image',
    Map<String, dynamic>? fields,
  }) async {
    try {
      final formData = FormData();

      print('=== MULTIPART REQUEST DEBUG ===');
      print('Endpoint: $endPoint');
      print('File: ${file?.path}');
      print('File Field Name: $fileFieldName');
      print('Fields: $fields');

      // Add file if provided
      if (file != null) {
        formData.files.add(
          MapEntry(
            fileFieldName,
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
        print('Added file: ${file.path.split('/').last}');
      }

      // Add other fields
      if (fields != null) {
        fields.forEach((key, value) {
          if (value != null) {
            formData.fields.add(MapEntry(key, value.toString()));
            print('Added field: $key = ${value.toString()}');
          }
        });
      }

      print('FormData fields: ${formData.fields}');
      print('FormData files: ${formData.files.length}');
      print('===============================');

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
      print('ERROR in postMultipartData: $e');
      rethrow;
    }
  }

  // PUT Request with Multipart (for profile image updates)
  Future<Response> putMultipartData(
      String endPoint, {
        File? file,
        String fileFieldName = 'image',
        Map<String, dynamic>? fields,
      }) async {
    try {
      final formData = FormData();

      print('=== MULTIPART PUT REQUEST DEBUG ===');
      print('Endpoint: $endPoint');
      print('File: ${file?.path}');
      print('File Field Name: $fileFieldName');
      print('Fields: $fields');

      // Add file if provided
      if (file != null) {
        formData.files.add(
          MapEntry(
            fileFieldName,
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
        print('Added file: ${file.path.split('/').last}');
      }

      // Add other fields
      if (fields != null) {
        fields.forEach((key, value) {
          if (value != null) {
            formData.fields.add(MapEntry(key, value.toString()));
            print('Added field: $key = ${value.toString()}');
          }
        });
      }

      print('FormData fields: ${formData.fields}');
      print('FormData files: ${formData.files.length}');
      print('===============================');

      final response = await dio.put(  // Use PUT instead of POST
        endPoint,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          validateStatus: (status) => true,
        ),
      );
      return response;
    } catch (e) {
      print('ERROR in putMultipartData: $e');
      rethrow;
    }
  }
}
