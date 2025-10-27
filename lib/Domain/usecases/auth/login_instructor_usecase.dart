import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/auth_repo.dart';
import 'package:dart_either/dart_either.dart';

class LoginInstructorUseCase {
  final AuthRepo repo;

  LoginInstructorUseCase(this.repo);

  Future<Either<Failures, InstructorEntity>> call({
    required String email,
    required String password,
  }) {
    return repo.loginInstructor(email: email, password: password);
  }
}
