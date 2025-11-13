import 'package:flutter/foundation.dart'; // Add this import

@immutable // Now this will work
abstract class EnrollState {}

class EnrollInitial extends EnrollState {}

class EnrollLoading extends EnrollState {}

class EnrollSuccess extends EnrollState {
  final String courseId;

  EnrollSuccess({required this.courseId});
}

class EnrollFailureState extends EnrollState {
  final String errorMessage;

  EnrollFailureState(this.errorMessage);
}
