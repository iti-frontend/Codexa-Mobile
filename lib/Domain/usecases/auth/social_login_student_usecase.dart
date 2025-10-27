import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:codexa_mobile/Domain/repo/auth_repo.dart';
import 'package:dart_either/dart_either.dart';

class SocialLoginStudentUseCase {
  final AuthRepo repo;

  SocialLoginStudentUseCase(this.repo);

  Future<Either<Failures, StudentEntity>> call({
    
    required String token,
  }) {
    return repo.socialLoginStudent( token: token);
  }
}
