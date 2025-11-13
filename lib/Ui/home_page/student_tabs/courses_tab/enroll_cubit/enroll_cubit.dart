import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Domain/usecases/courses/enroll_in_course_usecase.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/enroll_cubit/enroll_states.dart';

class EnrollCubit extends Cubit<EnrollState> {
  final EnrollInCourseUseCase enrollUseCase;

  EnrollCubit(this.enrollUseCase) : super(EnrollInitial());

  Future<void> enroll({
    required String token,
    required String courseId,
  }) async {
    emit(EnrollLoading());
    final result = await enrollUseCase(token: token, courseId: courseId);

    result.fold(
      (failure) => emit(EnrollFailureState(failure.errorMessage)),
      (_) => emit(
          EnrollSuccess(courseId: courseId)), // Add courseId to success state
    );
  }
}
