import 'package:codexa_mobile/Domain/usecases/courses/get_courses_usecase.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/enroll_cubit/enroll_courses_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnrollCubit extends Cubit<EnrollState> {
  final GetCoursesUseCase enrollUseCase;
  final String token;

  EnrollCubit({
    required this.enrollUseCase,
    required this.token,
  }) : super(EnrollInitial());

  Future<void> enroll({
    required String courseId,
  }) async {
    emit(EnrollLoading());

    try {
      final result = await enrollUseCase.callEnroll(
        courseId: courseId,
        token: token,
      );

      result.fold(
        (failure) => emit(EnrollFailureState(failure.errorMessage)),
        (_) => emit(EnrollSuccess(courseId: courseId)),
      );
    } catch (e) {
      emit(EnrollFailureState(e.toString()));
    }
  }
}
