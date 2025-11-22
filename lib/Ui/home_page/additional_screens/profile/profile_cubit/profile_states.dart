import 'package:codexa_mobile/Domain/failures.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess<T> extends ProfileState {
  final T user;
  ProfileSuccess(this.user);
}

class ProfileError extends ProfileState {
  final Failures failure;
  ProfileError(this.failure);
}
