abstract class EnrollState {}

class EnrollInitial extends EnrollState {}

class EnrollLoading extends EnrollState {}

class EnrollSuccess extends EnrollState {}

class EnrollFailureState extends EnrollState {
  final String message;
  EnrollFailureState(this.message);
}
