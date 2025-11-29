import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:dartz/dartz.dart';

abstract class GetCoursesRepo {
  Future<Either<Failures, List<CourseEntity>>> getCourses();
  Future<Either<Failures, List<CourseEntity>>> getInstructorCourses();
  Future<Either<Failures, bool>> enrollInCourse({required String courseId});
  Future<Either<Failures, bool>> toggleFavourite(String courseId);
  Future<Either<Failures, List<CourseEntity>>> getFavourites(
      {int page = 1, int limit = 10});
}
