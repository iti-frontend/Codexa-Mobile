import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';

class RegisterStates {}

class RegisterInitialState extends RegisterStates {}

class RegisterLoadingState extends RegisterStates {
  final String message;
  RegisterLoadingState({this.message = 'Loading...'});
}

class RegisterErrorState extends RegisterStates {
  final Failures failure;
  RegisterErrorState({required this.failure});
}

class StudentRegisterSuccessState extends RegisterStates {
  final StudentEntity student;
  StudentRegisterSuccessState({required this.student});
}

class InstructorRegisterSuccessState extends RegisterStates {
  final InstructorEntity instructor;
  InstructorRegisterSuccessState({required this.instructor});
}
