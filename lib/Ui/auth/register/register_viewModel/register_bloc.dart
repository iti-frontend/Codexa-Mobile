import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Domain/usecases/auth/register_instructor_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/register_student_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/social_login_instructor_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/auth/social_login_student_usecase.dart';
import 'register_state.dart';

class RegisterViewModel extends Cubit<RegisterStates> {
  final RegisterStudentUseCase registerStudentUseCase;
  final SocialLoginStudentUseCase socialLoginStudentUseCase;

  final RegisterInstructorUseCase registerInstructorUseCase;
  final SocialLoginInstructorUseCase socialLoginInstructorUseCase;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();

  RegisterViewModel({
    required this.registerStudentUseCase,
    required this.socialLoginStudentUseCase,
    required this.registerInstructorUseCase,
    required this.socialLoginInstructorUseCase,
  }) : super(RegisterInitialState());

  // ---------- Student Register ----------
  Future<void> registerStudent() async {
    emit(RegisterLoadingState(message: 'Registering student...'));

    final result = await registerStudentUseCase.call(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    result.fold(
      ifLeft: (failure) {
        emit(RegisterErrorState(failure: failure));
      },
      ifRight: (student) {
        emit(StudentRegisterSuccessState(student: student));
      },
    );
  }

  Future<void> socialRegisterStudent({required String token}) async {
    emit(RegisterLoadingState(message: 'Social register student...'));

    final result = await socialLoginStudentUseCase.call(token: token);

    result.fold(
      ifLeft: (failure) {
        emit(RegisterErrorState(failure: failure));
      },
      ifRight: (student) {
        emit(StudentRegisterSuccessState(student: student));
      },
    );
  }

  // ---------- Instructor Register ----------
  Future<void> registerInstructor() async {
    emit(RegisterLoadingState(message: 'Registering instructor...'));

    final result = await registerInstructorUseCase.call(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    result.fold(
      ifLeft: (failure) {
        emit(RegisterErrorState(failure: failure));
      },
      ifRight: (instructor) {
        emit(InstructorRegisterSuccessState(instructor: instructor));
      },
    );
  }

  Future<void> socialRegisterInstructor({required String token}) async {
    emit(RegisterLoadingState(message: 'Social register instructor...'));

    final result = await socialLoginInstructorUseCase.call(token: token);

    result.fold(
      ifLeft: (failure) {
        emit(RegisterErrorState(failure: failure));
      },
      ifRight: (instructor) {
        emit(InstructorRegisterSuccessState(instructor: instructor));
      },
    );
  }
}
