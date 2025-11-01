import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';

class AuthStates {}

// Initial
class AuthInitialState extends AuthStates {}

// Loading
class AuthLoadingState extends AuthStates {
  final String message;

  AuthLoadingState({this.message = 'Loading...'});
}

// Error
class AuthErrorState extends AuthStates {
  final Failures failure;

  AuthErrorState({required this.failure});
}

// Success - Student
class StudentAuthSuccessState extends AuthStates {
  final StudentEntity student;

  StudentAuthSuccessState({required this.student});
}

// Success - Instructor
class InstructorAuthSuccessState extends AuthStates {
  final InstructorEntity instructor;

  InstructorAuthSuccessState({required this.instructor});
}
