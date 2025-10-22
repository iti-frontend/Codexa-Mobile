import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/api_constants.dart';
import '../models/StudentUser.dart';
import '../models/InstructorUser.dart';

class ApiManager {
  static final ApiManager _instance = ApiManager._internal();
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? "";

  late Dio dio;

  factory ApiManager() => _instance;

  ApiManager._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('REQUEST: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE [${response.statusCode}]: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('ERROR [${error.response?.statusCode ?? ''}]: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // ==================== Student Endpoints ====================

  Future<StudentUser?> studentRegister({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.studentEndpointRegister,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );
      return StudentUser.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<StudentUser?> studentLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.studentEndpointLogin,
        data: {
          'email': email,
          'password': password,
        },
      );
      return StudentUser.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<dynamic> socialLoginStudent({
    required String tokenId,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.studentEndpointSocial,
        data: {
          'token': tokenId,
        },
      );

      return StudentUser.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }


  // ==================== Instructor Endpoints ====================

  Future<InstructorUser?> instructorRegister({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.instructorEndpointRegister,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );
      return InstructorUser.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<InstructorUser?> instructorLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.instructorEndpointLogin,
        data: {
          'email': email,
          'password': password,
        },
      );
      return InstructorUser.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // ==================== Social Login (New) ====================

  Future<dynamic> socialLogin({
    required String tokenId,
  }) async {
    try {
      final response = await dio.post(
      ApiConstants.instructorEndpointSocial,
        data: {
          'token': tokenId,
        },
      );

      return InstructorUser.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // ==================== Error Handling ====================

  void _handleError(DioException error) {
    String message = 'Unexpected error occurred';

    if (error.response != null) {
      message = error.response?.data['message'] ?? 'Server error';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = 'Receive timeout';
    } else if (error.type == DioExceptionType.unknown) {
      message = 'Check your internet connection';
    }

    print('API Error: $message');
  }
}
