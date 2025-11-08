import 'package:codexa_mobile/Domain/usecases/courses/get_courses_usecase.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/courses_tab/courses_cubit/instructor_courses_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InstructorCoursesCubit extends Cubit<InstructorCoursesStates> {
  final GetCoursesUseCase getInstructorCoursesUseCase;

  InstructorCoursesCubit(this.getInstructorCoursesUseCase)
      : super(InstructorCoursesInitialState());

  Future<void> getInstructorCourses() async {
    emit(InstructorCoursesLoadingState());
    final result = await getInstructorCoursesUseCase.instructorCall();

    result.fold(
      (failure) => emit(InstructorCoursesErrorState(failure.errorMessage)),
      (courses) => emit(InstructorCoursesSuccessState(courses)),
    );
  }
}
