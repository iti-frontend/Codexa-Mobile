import 'package:codexa_mobile/Data/api_manager/api_manager.dart';
import 'package:codexa_mobile/Data/constants/api_constants.dart';
import 'package:codexa_mobile/Data/models/courses_dto.dart';
import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/get_courses_repo.dart';
import 'package:dartz/dartz.dart';

class CoursesRepoImpl implements GetCoursesRepo {
  final ApiManager apiManager;

  CoursesRepoImpl(this.apiManager);
// !=============================================Student Courses=========================================
  @override
  Future<Either<Failures, List<CourseEntity>>> getCourses() async {
    try {
      print('DEBUG: CoursesRepoImpl.getCourses called');
      final response = await apiManager.getData(ApiConstants.coursesEndpoint);
      print('DEBUG: Courses API Response Status: ${response.statusCode}');
      print('DEBUG: Courses API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> dataList = (data is Map && data['data'] != null)
            ? (data['data'] as List<dynamic>)
            : (data is List ? data : []);

        print('DEBUG: Parsed dataList length: ${dataList.length}');

        final List<CourseEntity> courses = dataList
            .map((item) => CoursesDto.fromJson(item as Map<String, dynamic>))
            .toList();
        return Right(courses);
      } else {
        return Left(Failures(
            errorMessage:
                response.data?['message']?.toString() ?? 'Server Error'));
      }
    } catch (e) {
      print('DEBUG: CoursesRepoImpl Error: $e');
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  // ! =========================================Enroll Courses===================================

  @override
  Future<Either<Failures, bool>> enrollInCourse({
    required String courseId,
  }) async {
    try {
      final response = await apiManager.postData(
        ApiConstants.enrollCourseEndpoint(courseId),
        body: {},
      );

      print('Enroll response status: ${response.statusCode}');
      print('Enroll response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(true);
      }

      // Handle error
      String errorMessage = 'Failed to enroll in course';
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

      return Left(Failures(errorMessage: errorMessage));
    } catch (e, stack) {
      print('Enroll exception: $e');
      print('Stack trace: $stack');
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  // ! ==================================== Instructor Courses ====================================
  @override
  Future<Either<Failures, List<CourseEntity>>> getInstructorCourses() async {
    try {
      final response =
          await apiManager.getData(ApiConstants.coursesInstructorEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> dataList = (data is Map && data['data'] != null)
            ? (data['data'] as List<dynamic>)
            : (data is List ? data : []);

        final List<CourseEntity> courses = dataList
            .map((item) => CoursesDto.fromJson(item as Map<String, dynamic>))
            .toList();
        return Right(courses);
      } else {
        return Left(Failures(
          errorMessage: response.data?['message']?.toString() ?? 'Server Error',
        ));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }
}
