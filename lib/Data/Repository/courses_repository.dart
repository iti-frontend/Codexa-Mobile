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

  @override
  Future<Either<Failures, bool>> toggleFavourite(String courseId) async {
    try {
      print('🔵 [REPO] toggleFavourite: Starting for courseId: $courseId');

      final response = await apiManager.postData(
        ApiConstants.addCourseToFavorite,
        body: {'courseId': courseId},
      );

      print(
          '🔵 [REPO] toggleFavourite: Response status: ${response.statusCode}');
      print('🔵 [REPO] toggleFavourite: Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Backend returns: { "status": "added" } or { "status": "removed" }
        if (data is Map<String, dynamic>) {
          final status = data['status'] as String?;

          if (status == 'added') {
            print(
                '🟢 [REPO] toggleFavourite: Success! Course ADDED to favourites (isFavourite = true)');
            return const Right(true);
          } else if (status == 'removed') {
            print(
                '🟢 [REPO] toggleFavourite: Success! Course REMOVED from favourites (isFavourite = false)');
            return const Right(false);
          }

          // Fallback: try old format
          final isFavourite = data['isFavourite'] as bool? ??
              data['data']?['isFavourite'] as bool?;

          if (isFavourite != null) {
            print(
                '🟢 [REPO] toggleFavourite: Success! isFavourite = $isFavourite (old format)');
            return Right(isFavourite);
          }
        }

        // If we can't parse, assume success means added
        print(
            '🟡 [REPO] toggleFavourite: Could not parse response, defaulting to true');
        return const Right(true);
      } else {
        print(
            '🔴 [REPO] toggleFavourite: Failed with status ${response.statusCode}');
        return Left(
            Failures(errorMessage: response.statusMessage ?? 'Unknown Error'));
      }
    } catch (e) {
      print('🔴 [REPO] toggleFavourite: Exception - $e');
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, List<CourseEntity>>> getFavourites(
      {int page = 1, int limit = 10}) async {
    try {
      print('🔵 [REPO] getFavourites: Fetching page=$page, limit=$limit');

      final response = await apiManager.getData(
        ApiConstants.getFavoriteCourses,
        query: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      print('🔵 [REPO] getFavourites: Response status: ${response.statusCode}');
      print(
          '🔵 [REPO] getFavourites: Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Backend returns: { "total": 5, "page": 1, "items": [...] }
        List<dynamic> dataList = [];

        if (data is Map && data['items'] != null) {
          // New format: { items: [...] }
          dataList = data['items'] as List<dynamic>;
          print(
              '🟢 [REPO] getFavourites: Found ${dataList.length} items in "items" field');
        } else if (data is Map && data['data'] != null) {
          // Old format: { data: [...] }
          dataList = data['data'] as List<dynamic>;
          print(
              '🟢 [REPO] getFavourites: Found ${dataList.length} items in "data" field');
        } else if (data is List) {
          // Direct array
          dataList = data;
          print(
              '🟢 [REPO] getFavourites: Response is direct array with ${dataList.length} items');
        }

        // Extract course from each favourite item
        final List<CourseEntity> courses = dataList.map((item) {
          // Backend returns: { _id, student, course: {...}, createdAt }
          // We need to extract the "course" object
          if (item is Map<String, dynamic> && item['course'] != null) {
            final courseData = item['course'] as Map<String, dynamic>;

            // Debug: Print the course data structure
            print('🔵 [REPO] Course data keys: ${courseData.keys.toList()}');
            print('🔵 [REPO] Course title: ${courseData['title']}');
            print('🔵 [REPO] Course instructor: ${courseData['instructor']}');
            print(
                '🔵 [REPO] Course instructor type: ${courseData['instructor']?.runtimeType}');

            // Add isFavourite: true since it's in favourites list
            courseData['isFavourite'] = true;
            return CoursesDto.fromJson(courseData);
          }
          // Fallback: item is the course itself
          print(
              '🟡 [REPO] Item is the course itself (no nested course object)');
          return CoursesDto.fromJson(item as Map<String, dynamic>);
        }).toList();

        print(
            '🟢 [REPO] getFavourites: Successfully parsed ${courses.length} courses');
        return Right(courses);
      } else {
        print(
            '🔴 [REPO] getFavourites: Failed with status ${response.statusCode}');
        return Left(
            Failures(errorMessage: response.statusMessage ?? 'Unknown Error'));
      }
    } catch (e) {
      print('🔴 [REPO] getFavourites: Exception - $e');
      return Left(Failures(errorMessage: e.toString()));
    }
  }
}
