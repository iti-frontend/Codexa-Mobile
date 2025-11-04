import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Data/constants/api_constants.dart';
import 'package:codexa_mobile/Data/models/courses_dto.dart';
import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/get_courses_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class CoursesRepoImpl implements GetCoursesRepo {
  final ApiManager apiManager;

  CoursesRepoImpl(this.apiManager);

  @override
  Future<Either<Failures, List<CourseEntity>>> getCourses() async {
    try {
      final response = await apiManager.getData(ApiConstants.coursesEndpoint);
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> dataList = (data is Map && data['data'] != null)
            ? (data['data'] as List<dynamic>)
            : (data is List ? data : []);

        final List<CourseEntity> courses = dataList
            .map((item) => CoursesDto.fromJson(item as Map<String, dynamic>))
            .toList();
        for (var item in courses) {
          print(item.id);
        }
        return Right(courses);
      } else {
        return Left(Failures(
            errorMessage:
                response.data?['message']?.toString() ?? 'Server Error'));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, bool>> enrollInCourse({
    required String token,
    required String courseId,
  }) async {
    try {
      final response = await apiManager.postData(
        ApiConstants.enrollCourseEndpoint(courseId),
        body: {},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => true,
        ),
      );

      print('Enroll response status: ${response.statusCode}');
      print('Enroll response data: ${response.data}');

      // Handle success
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(true);
      }

      // Handle error response safely
      dynamic errorMessage = 'Failed to enroll in course';
      final data = response.data;

      if (data != null) {
        if (data is Map<String, dynamic>) {
          errorMessage = data['message']?.toString() ?? errorMessage;
        } else if (data is List && data.isNotEmpty) {
          errorMessage = data.first.toString();
        } else if (data is String) {
          errorMessage = data;
        }
      }

      final fullUrl = apiManager.dio.options.baseUrl +
          ApiConstants.enrollCourseEndpoint(courseId);
      print("POST URL: $fullUrl");

      return Left(Failures(errorMessage: errorMessage));
    } catch (e, stack) {
      print('Enroll exception: $e');
      print('Stack trace: $stack');
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, List<CourseEntity>>> getMyCourses(
      String token) async {
    try {
      final response = await apiManager.getData(
        ApiConstants.studentCoursesEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final rawData = response.data;
        final List<dynamic> dataList =
            (rawData is Map && rawData['data'] != null)
                ? rawData['data'] as List<dynamic>
                : (rawData is List ? rawData : []);

        final courses = dataList
            .map((e) => CoursesDto.fromJson(e as Map<String, dynamic>))
            .toList();

        return Right(courses);
      } else {
        return Left(Failures(errorMessage: 'Failed to fetch my courses'));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }
}
