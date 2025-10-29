// lib/src/ui/courses/student_courses_cubit.dart

import 'package:codexa_mobile/Domain/usecases/courses/get_courses_usecase.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentCoursesCubit extends Cubit<StudentCoursesState> {
  final GetCoursesUseCase getStudentCoursesUseCase;
  StudentCoursesCubit(this.getStudentCoursesUseCase)
      : super(StudentCoursesInitial());

  Future<void> fetchCourses() async {
    emit(StudentCoursesLoading());
    final result = await getStudentCoursesUseCase();
    result.fold(
      (failure) => emit(StudentCoursesError(failure.errorMessage)),
      (courses) => emit(StudentCoursesLoaded(courses)),
    );
  }
}
