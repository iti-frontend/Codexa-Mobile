import 'dart:io';

import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:dartz/dartz.dart';

abstract class CourseInstructorRepo {
  Future<Either<Failures, CourseEntity>> addCourse(CourseEntity course);
  Future<Either<Failures, List<CourseEntity>>> getMyCourses();
  Future<Either<Failures, CourseEntity>> getCourseById(String id);
  Future<Either<Failures, CourseEntity>> updateCourse(CourseEntity course);
  Future<Either<Failures, CourseEntity>> deleteCourse(String id);
  Future<Either<Failures, List<String>>> uploadVideos(
      String id, List<File> files);
}
