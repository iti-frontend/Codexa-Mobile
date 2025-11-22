import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/profile_repo.dart';
import 'package:dartz/dartz.dart';

abstract class UpdateProfileUseCase<T> {
  Future<Either<Failures, T>> call(T user);
}
