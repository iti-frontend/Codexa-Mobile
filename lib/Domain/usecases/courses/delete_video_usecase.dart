import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/add_course_repo.dart';
import 'package:dartz/dartz.dart';

class DeleteVideoUseCase {
  final CourseInstructorRepo repo;

  DeleteVideoUseCase(this.repo);

  Future<Either<Failures, void>> call(String courseId, String videoId) async {
    return await repo.deleteVideo(courseId, videoId);
  }
}
