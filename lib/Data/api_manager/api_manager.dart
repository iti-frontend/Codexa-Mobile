import 'package:codexa_mobile/Data/constants/api_constants.dart';
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
  
  // PUT Request with Multipart (for profile image updates)
  Future<Response> putMultipartData(
      String endPoint, {
        File? file,
        String fileFieldName = 'profileImage',
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

// Voice to Text API
  Future<Response> voiceToText(File audioFile) async {
    try {
      print('=== VOICE TO TEXT REQUEST ===');
      print('Audio file: ${audioFile.path}');

      // Get file extension
      final extension = audioFile.path.split('.').last.toLowerCase();
      print('File extension: $extension');

      // Force .webm filename for ElevenLabs
      String filename = 'audio.webm';

      // Read and verify file
      final fileBytes = await audioFile.readAsBytes();
      print('File bytes: ${fileBytes.length}');

      if (fileBytes.isEmpty) {
        throw Exception('Audio file is empty');
      }

      // Create form data - MUST use field name "file" and filename "audio.webm"
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioFile.path,
          filename: filename, // Important: Must be audio.webm
        ),
      });

      print('Sending to ElevenLabs via backend...');
      print('Using filename: $filename');

      final response = await dio.post(
        '/ai/voice-to-text',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          responseType: ResponseType.json, // Ensure JSON response
          validateStatus: (status) => status! < 600,
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 500) {
        print('ElevenLabs error details: ${response.data}');
      }

      return response;
    } catch (e) {
      print('Voice to Text error: $e');
      rethrow;
    }
  }
// Text to Voice API
  Future<Response> textToVoice(String text) async {
    try {
      final response = await dio.post(
        ApiConstants.textToVoiceEndpoint,
        data: {'text': text},
        options: Options(
          responseType: ResponseType.bytes, // Important for audio bytes
          validateStatus: (status) => true,
        ),
      );
      return response;
    } catch (e) {
      print('Text to Voice error: $e');
      rethrow;
    }
  }

// Chat AI API
  Future<Response> chatAI(String message, {List<Map<String, dynamic>>? history}) async {
    try {
      final response = await dio.post(
        ApiConstants.chatAIEndpoint,
        data: {
          'message': message,
          'history': history ?? [],
        },
        options: Options(validateStatus: (status) => true),
      );
      return response;
    } catch (e) {
      print('Chat AI error: $e');
      rethrow;
    }
  }
}
