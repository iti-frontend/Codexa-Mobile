import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/auth_repo.dart';
import 'package:dart_either/dart_either.dart';

class RegisterStudentUseCase {
  final AuthRepo repo;

  RegisterStudentUseCase(this.repo);

  Future<Either<Failures, StudentEntity>> call({
    required String name,
    required String email,
    required String password,
  }) {
    return repo.registerStudent(name: name, email: email, password: password);
  }
}
