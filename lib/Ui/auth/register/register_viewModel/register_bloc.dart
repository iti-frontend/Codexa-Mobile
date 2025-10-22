import 'package:codexa_mobile/Ui/auth/register/register_viewModel/register_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../Data/Repository/auth_repository.dart';
import 'register_event.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _repo;

  RegisterBloc(this._repo) : super(RegisterInitial()) {
    on<RegisterStudentSubmitted>(_onStudentRegister);
    on<RegisterInstructorSubmitted>(_onInstructorRegister);
  }

  Future<void> _onStudentRegister(
      RegisterStudentSubmitted event,
      Emitter<RegisterState> emit,
      ) async {
    emit(RegisterLoading());
    try {
      final result = await _repo.registerStudent(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      if (result != null && result.token != null) {
        emit(RegisterSuccess(token: result.token!));
      } else {
        emit(const RegisterFailure('Student registration failed'));
      }
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }

  Future<void> _onInstructorRegister(
      RegisterInstructorSubmitted event,
      Emitter<RegisterState> emit,
      ) async {
    emit(RegisterLoading());
    try {
      final result = await _repo.registerInstructor(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      if (result != null && result.token != null) {
        emit(RegisterSuccess(token: result.token!));
      } else {
        emit(const RegisterFailure('Instructor registration failed'));
      }
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}