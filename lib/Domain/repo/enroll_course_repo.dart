import 'package:codexa_mobile/Domain/failures.dart';
import 'package:dartz/dartz.dart';

abstract class EnrollCourseRepo {
  Future<Either<Failures, bool>> enrollInCourse({
    required String token,
    required String courseId,
  });
}
