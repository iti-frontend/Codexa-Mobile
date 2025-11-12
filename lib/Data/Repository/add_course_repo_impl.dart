import 'dart:io';

import 'package:codexa_mobile/Data/constants/api_constants.dart';
import 'package:codexa_mobile/Data/models/courses_dto.dart';
import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/add_course_repo.dart';
import 'package:dartz/dartz.dart';
import '../api_manager/api_manager.dart';

class CourseInstructorRepoImpl implements CourseInstructorRepo {
  final ApiManager apiManager;

  CourseInstructorRepoImpl({required this.apiManager});

  @override
  Future<Either<Failures, CourseEntity>> addCourse(CourseEntity course) async {
    try {
      final body = {
        'title': course.title,
        'description': course.description,
        'category': course.category,
        'price': course.price ?? 0,
        'videos': course.videos ?? [],
      };

      final response = await apiManager.postData(
        ApiConstants.coursesEndpoint,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Right(course);
      } else {
        return Left(Failures(
          errorMessage:
              response.data?['message']?.toString() ?? 'Failed to add course',
        ));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, List<CourseEntity>>> getMyCourses() async {
    try {
      final response =
          await apiManager.getData(ApiConstants.coursesInstructorEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> dataList = (data is Map && data['data'] != null)
            ? (data['data'] as List<dynamic>)
            : (data is List ? data : []);

        final courses = dataList.map((e) => CoursesDto.fromJson(e)).toList();

        return Right(courses);
      } else {
        return Left(Failures(
          errorMessage:
              response.data?['message']?.toString() ?? 'Failed to load courses',
        ));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, CourseEntity>> getCourseById(String id) async {
    try {
      final response =
          await apiManager.getData(ApiConstants.courseInstructorById(id));

      if (response.statusCode == 200) {
        final data = response.data;
        final course = CoursesDto.fromJson(data is Map<String, dynamic>
            ? data
            : Map<String, dynamic>.from(data));
        return Right(course);
      } else {
        return Left(Failures(
          errorMessage:
              response.data?['message']?.toString() ?? 'Course not found',
        ));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, CourseEntity>> updateCourse(
      CourseEntity course) async {
    try {
      final body = {
        'title': course.title,
        'description': course.description,
        'category': course.category,
        'price': course.price ?? 0,
        'videos': course.videos ?? [],
      };

      final response = await apiManager.putData(
        ApiConstants.courseInstructorById(course.id!),
        body: body,
      );

      if (response.statusCode == 200) {
        return Right(course);
      } else {
        return Left(Failures(
          errorMessage: response.data?['message']?.toString() ??
              'Failed to update course',
        ));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, CourseEntity>> deleteCourse(String id) async {
    if (id.isEmpty) {
      return Left(Failures(errorMessage: 'Course ID is empty'));
    }

    try {
      final response =
          await apiManager.deleteData(ApiConstants.courseInstructorById(id));

      if (response.statusCode == 200 || response.statusCode == 204) {
        final deletedCourse =
            CourseEntity(id: id, title: '', category: '', description: '');
        return Right(deletedCourse);
      } else {
        return Left(Failures(
          errorMessage: response.data?['message']?.toString() ??
              'Failed to delete course',
        ));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failures, List<String>>> uploadVideos(
    String courseId,
    List<File> files,
  ) async {
    if (files.isEmpty) {
      return Left(Failures(errorMessage: 'No videos selected'));
    }

    try {
      final response = await apiManager.uploadData(
        ApiConstants.courseInstructorVideos(courseId),
        files,
        fieldName: 'videos',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        List<String> urls = [];
        if (data is List) {
          urls = List<String>.from(data);
        } else if (data is Map && data['videos'] != null) {
          urls = List<String>.from(data['videos']);
        }

        return Right(urls);
      } else {
        return Left(Failures(
          errorMessage: response.data?['message']?.toString() ??
              'Failed to upload course videos',
        ));
      }
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }
}
