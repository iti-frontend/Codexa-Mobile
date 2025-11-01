import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/get_courses_repo.dart';
import 'package:dartz/dartz.dart';

class GetCoursesUseCase {
  final GetCoursesRepo repo;
  GetCoursesUseCase(this.repo);

  Future<Either<Failures, List<CourseEntity>>> call() {
    return repo.getCourses();
  }
}
