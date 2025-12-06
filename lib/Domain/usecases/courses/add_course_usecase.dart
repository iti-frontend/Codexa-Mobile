import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:dartz/dartz.dart';
import '../../repo/add_course_repo.dart';
import '../../failures.dart';

class AddCourseUseCase {
  final CourseInstructorRepo repo;

  AddCourseUseCase(this.repo);

  Future<Either<Failures, CourseEntity>> call(CourseEntity course) {
    return repo.addCourse(course);
  }
}
