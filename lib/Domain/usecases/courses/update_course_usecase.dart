import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:dartz/dartz.dart';
import '../../repo/add_course_repo.dart';
import '../../failures.dart';

class UpdateCourseUseCase {
  final CourseInstructorRepo repo;

  UpdateCourseUseCase(this.repo);

  Future<Either<Failures, void>> call(CourseEntity course) async {
    try {
      await repo.updateCourse(course);
      return const Right(null);
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }
}
