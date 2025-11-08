import 'package:codexa_mobile/Domain/entities/add_course_entity.dart';
import 'package:dartz/dartz.dart';
import '../../repo/add_course_repo.dart';
import '../../failures.dart';

class GetCourseByIdUseCase {
  final CourseInstructorRepo repo;

  GetCourseByIdUseCase(this.repo);

  Future<Either<Failures, CourseInstructorEntity>> call(String id) async {
    try {
      final course = await repo.getCourseById(id);
      return Right(course);
    } catch (e) {
      return Left(Failures(errorMessage: e.toString()));
    }
  }
}
