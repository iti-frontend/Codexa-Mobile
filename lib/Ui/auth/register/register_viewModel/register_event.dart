import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
  @override
  List<Object?> get props => [];
}

class RegisterStudentSubmitted extends RegisterEvent {
  final String name;
  final String email;
  final String password;

  const RegisterStudentSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class RegisterInstructorSubmitted extends RegisterEvent {
  final String name;
  final String email;
  final String password;

  const RegisterInstructorSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}