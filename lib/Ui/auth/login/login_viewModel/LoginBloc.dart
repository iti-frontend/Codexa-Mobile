import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Domain/usecases/auth/login_instructor_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/login_student_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/register_instructor_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/register_student_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/social_login_instructor_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/social_login_student_usecase.dart';
import 'login_state.dart';

class AuthViewModel extends Cubit<AuthStates> {
  final LoginStudentUseCase loginStudentUseCase;
  final RegisterStudentUseCase registerStudentUseCase;
  final SocialLoginStudentUseCase socialLoginStudentUseCase;

  final LoginInstructorUseCase loginInstructorUseCase;
  final RegisterInstructorUseCase registerInstructorUseCase;
  final SocialLoginInstructorUseCase socialLoginInstructorUseCase;

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();

  AuthViewModel({
    required this.loginStudentUseCase,
    required this.registerStudentUseCase,
    required this.socialLoginStudentUseCase,
    required this.loginInstructorUseCase,
    required this.registerInstructorUseCase,
    required this.socialLoginInstructorUseCase,
  }) : super(AuthInitialState());

  // ---------- Student ----------
  Future<void> loginStudent() async {
    emit(AuthLoadingState(message: 'Logging in student...'));
    final result = await loginStudentUseCase.call(
      email: emailController.text,
      password: passwordController.text,
    );

    result.fold(ifLeft: (failure) {
      emit(AuthErrorState(failure: failure));
    }, ifRight: (student) {
      emit(StudentAuthSuccessState(student: student));
    });
  }

  Future<void> registerStudent() async {
    emit(AuthLoadingState(message: 'Registering student...'));
    final result = await registerStudentUseCase.call(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    result.fold(
      ifLeft: (failure) {
        emit(AuthErrorState(failure: failure));
      },
      ifRight: (student) {
        emit(StudentAuthSuccessState(student: student));
      },
    );
  }

  Future<void> socialLoginStudent(
      { required String token}) async {
    emit(AuthLoadingState(message: 'Social login student...'));
    final result =
        await socialLoginStudentUseCase.call(token: token);

    result.fold(
      ifLeft: (failure) {
        emit(AuthErrorState(failure: failure));
      },
      ifRight: (student) {
        emit(StudentAuthSuccessState(student: student));
      },
    );
  }

  // ---------- Instructor ----------
  Future<void> loginInstructor() async {
    emit(AuthLoadingState(message: 'Logging in instructor...'));
    final result = await loginInstructorUseCase.call(
      email: emailController.text,
      password: passwordController.text,
    );

    result.fold(
      ifLeft: (failure) {
        emit(AuthErrorState(failure: failure));
      },
      ifRight: (instructor) {
        emit(InstructorAuthSuccessState(instructor: instructor));
      },
    );
  }

  Future<void> registerInstructor() async {
    emit(AuthLoadingState(message: 'Registering instructor...'));
    final result = await registerInstructorUseCase.call(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    result.fold(
      ifLeft: (failure) {
        emit(AuthErrorState(failure: failure));
      },
      ifRight: (instructor) {
        emit(InstructorAuthSuccessState(instructor: instructor));
      },
    );
  }

  Future<void> socialLoginInstructor(
      { required String token}) async {
    emit(AuthLoadingState(message: 'Social login instructor...'));
    final result = await socialLoginInstructorUseCase.call(
         token: token);
    result.fold(
      ifLeft: (failure) {
        emit(AuthErrorState(failure: failure));
      },
      ifRight: (instructor) {
        emit(InstructorAuthSuccessState(instructor: instructor));
      },
    );
  }
}
