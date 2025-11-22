// domain/usecases/profile/update_instructor_profile_usecase.dart
import 'package:codexa_mobile/Domain/usecases/profile/update_profile_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/profile_repo.dart';

class UpdateInstructorProfileUseCase
    implements UpdateProfileUseCase<InstructorEntity> {
  final ProfileRepo repository;

  UpdateInstructorProfileUseCase(this.repository);

  @override
  Future<Either<Failures, InstructorEntity>> call(
      InstructorEntity instructor) async {
    return await repository.updateInstructorProfile(instructor);
  }
}
