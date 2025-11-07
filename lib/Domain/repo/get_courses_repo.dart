import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:dartz/dartz.dart';

abstract class GetCoursesRepo {
  Future<Either<Failures, List<CourseEntity>>> getCourses();
  Future<Either<Failures, List<CourseEntity>>> getMyCourses(String token);
}
