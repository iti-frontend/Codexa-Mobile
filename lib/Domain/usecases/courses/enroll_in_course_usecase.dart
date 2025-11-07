import 'package:codexa_mobile/Data/Repository/courses_repository.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:dartz/dartz.dart';

class EnrollInCourseUseCase {
  final CoursesRepoImpl repo;
  EnrollInCourseUseCase(this.repo);

  Future<Either<Failures, bool>> call({
    required String token,
    required String courseId,
  }) {
    return repo.enrollInCourse(token: token, courseId: courseId);
  }
}
