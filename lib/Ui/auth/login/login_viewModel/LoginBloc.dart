import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../Data/Repository/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _repo;

  LoginBloc(this._repo) : super(LoginInitial()) {
    on<LoginStudentSubmitted>(_onStudentLogin);
    on<LoginInstructorSubmitted>(_onInstructorLogin);
    on<SocialLoginEvent>(_onSocialLogin);
  }

  Future<void> _onStudentLogin(
      LoginStudentSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final user = await _repo.loginStudent(
          email: event.email, password: event.password);
      if (user != null && user.token != null) {
        emit(LoginSuccess(user: user, role: 'student'));
      } else {
        emit(const LoginFailure('Student login failed'));
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onInstructorLogin(
      LoginInstructorSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final user = await _repo.loginInstructor(
          email: event.email, password: event.password);
      if (user != null && user.token != null) {
        emit(LoginSuccess(user: user, role: 'instructor'));
      } else {
        emit(const LoginFailure('Instructor login failed'));
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onSocialLogin(
      SocialLoginEvent event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final user =
      await _repo.socialLogin(role: event.role, tokenId: event.tokenId);
      if (user != null && user.token != null) {
        emit(LoginSuccess(user: user, role: event.role));
      } else {
        emit(const LoginFailure('Social login failed'));
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
