import 'package:codexa_mobile/Domain/repo/get_courses_repo.dart';
import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:codexa_mobile/Domain/failures.dart';

class GetMyCoursesUseCase {
  final GetCoursesRepo repo;
  GetMyCoursesUseCase(this.repo);

  Future<Either<Failures, List<CourseEntity>>> call(String token) {
    return repo.getMyCourses(token);
  }
}
