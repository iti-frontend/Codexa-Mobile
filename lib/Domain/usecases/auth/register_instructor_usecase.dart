import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/auth_repo.dart';
import 'package:dart_either/dart_either.dart';

class RegisterInstructorUseCase {
  final AuthRepo repo;

  RegisterInstructorUseCase(this.repo);

  Future<Either<Failures, InstructorEntity>> call({
    required String name,
    required String email,
    required String password,
  }) {
    return repo.registerInstructor(
        name: name, email: email, password: password);
  }
}
