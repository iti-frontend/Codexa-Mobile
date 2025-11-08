import 'package:dartz/dartz.dart';
import '../../repo/add_course_repo.dart';
import '../../failures.dart';

class DeleteCourseUseCase {
  final CourseInstructorRepo repo;

  DeleteCourseUseCase(this.repo);

  Future<Either<Failures, void>> call(String id) async {
    try {
      await repo.deleteCourse(id);
      return const Right(null);
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }
}
