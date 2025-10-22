import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class LoginStudentSubmitted extends LoginEvent {
  final String email;
  final String password;

  const LoginStudentSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class LoginInstructorSubmitted extends LoginEvent {
  final String email;
  final String password;

  const LoginInstructorSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SocialLoginEvent extends LoginEvent {
  final String role;
  final String tokenId;

  const SocialLoginEvent({
    required this.role,
    required this.tokenId,
  });

  @override
  List<Object?> get props => [role, tokenId];
}
