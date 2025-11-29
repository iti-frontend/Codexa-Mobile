import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/get_courses_repo.dart';
import 'package:dartz/dartz.dart';

class GetFavouritesUseCase {
  final GetCoursesRepo repo;

  GetFavouritesUseCase(this.repo);

  Future<Either<Failures, List<CourseEntity>>> call(
      {int page = 1, int limit = 10}) {
    return repo.getFavourites(page: page, limit: limit);
  }
}
