import 'package:codexa_mobile/Domain/failures.dart';
import 'package:dart_either/dart_either.dart';
import '../entities/instructor_entity.dart';
import '../entities/student_entity.dart';

abstract class AuthRepo {
  // ================== Instructor ==================
  Future<Either<Failures, InstructorEntity>> loginInstructor({
    required String email,
    required String password,
  });

  Future<Either<Failures, InstructorEntity>> registerInstructor({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failures, InstructorEntity>> socialLoginInstructor({
    required String token,
  });

  // ================== Student ==================
  Future<Either<Failures, StudentEntity>> loginStudent({
    required String email,
    required String password,
  });

  Future<Either<Failures, StudentEntity>> registerStudent({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failures, StudentEntity>> socialLoginStudent({
    required String token,
  });
}
