// domain/repositories/profile_repository.dart
import 'package:dartz/dartz.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';

abstract class ProfileRepo {
  Future<Either<Failures, StudentEntity>> updateStudentProfile(
      StudentEntity student);
  Future<Either<Failures, InstructorEntity>> updateInstructorProfile(
      InstructorEntity instructor);
}
