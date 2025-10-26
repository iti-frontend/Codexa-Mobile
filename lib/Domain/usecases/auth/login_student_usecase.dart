import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/auth_repo.dart';
import 'package:dart_either/dart_either.dart';

class LoginStudentUseCase {
  final AuthRepo repo;

  LoginStudentUseCase(this.repo);

  Future<Either<Failures, StudentEntity>> call({
    required String email,
    required String password,
  }) {
    return repo.loginStudent(email: email, password: password);
  }
}
