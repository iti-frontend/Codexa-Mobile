import 'package:equatable/equatable.dart';


abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final dynamic user;
  final String role;
  const LoginSuccess({required this.user, required this.role});

  @override
  List<Object?> get props => [user, role];
}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}


// ================= Social Login States =================

class SocialLoginLoading extends LoginState {}

class SocialLoginSuccess extends LoginState {
  final dynamic user; // StudentUser أو InstructorUser
  const SocialLoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class SocialLoginFailure extends LoginState {
  final String message;
  const SocialLoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}
