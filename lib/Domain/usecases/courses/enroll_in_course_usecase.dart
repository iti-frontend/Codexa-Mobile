import 'package:codexa_mobile/Domain/repo/get_courses_repo.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:dartz/dartz.dart';

class EnrollInCourseUseCase {
  final GetCoursesRepo repo;
  EnrollInCourseUseCase(this.repo);

  Future<Either<Failures, bool>> call({
    required String token,
    required String courseId,
  }) {
    return repo.enrollInCourse(token: token, courseId: courseId);
  }
}
