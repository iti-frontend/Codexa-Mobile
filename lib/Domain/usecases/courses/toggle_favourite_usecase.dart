import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/get_courses_repo.dart';
import 'package:dartz/dartz.dart';

class ToggleFavouriteUseCase {
  final GetCoursesRepo repo;

  ToggleFavouriteUseCase(this.repo);

  Future<Either<Failures, bool>> call(String courseId) {
    return repo.toggleFavourite(courseId);
  }
}
