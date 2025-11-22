// domain/usecases/profile/update_student_profile_usecase.dart
import 'package:codexa_mobile/Domain/usecases/profile/update_profile_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/profile_repo.dart';

class UpdateStudentProfileUseCase
    implements UpdateProfileUseCase<StudentEntity> {
  final ProfileRepo repository;

  UpdateStudentProfileUseCase(this.repository);

  @override
  Future<Either<Failures, StudentEntity>> call(StudentEntity student) async {
    return await repository.updateStudentProfile(student);
  }
}
