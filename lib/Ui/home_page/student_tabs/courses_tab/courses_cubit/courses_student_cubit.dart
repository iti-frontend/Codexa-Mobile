// lib/src/ui/courses/student_courses_cubit.dart

import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Domain/usecases/courses/get_courses_usecase.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentCoursesCubit extends Cubit<StudentCoursesState> {
  final GetCoursesUseCase getStudentCoursesUseCase;

  List<CourseEntity> allCourses = [];
  List<CourseEntity> filteredCourses = [];

  StudentCoursesCubit(this.getStudentCoursesUseCase)
      : super(StudentCoursesInitial());

  Future<void> fetchCourses() async {
    emit(StudentCoursesLoading());
    final result = await getStudentCoursesUseCase();
    result.fold(
      (failure) => emit(StudentCoursesError(failure.errorMessage)),
      (courses) {
        allCourses = courses;
        filteredCourses = courses;
        emit(StudentCoursesLoaded(filteredCourses));
      },
    );
  }

  void searchCourses(String query) {
    if (query.isEmpty) {
      filteredCourses = allCourses;
    } else {
      filteredCourses = allCourses
          .where((course) =>
              course.title!.toLowerCase().contains(query.toLowerCase()) ||
              (course.description
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ??
                  false))
          .toList();
    }
    emit(StudentCoursesLoaded(filteredCourses));
  }

  void filterByCategory(String category) {
    if (category == "All") {
      filteredCourses = allCourses;
    } else {
      filteredCourses = allCourses
          .where((course) =>
              course.category?.toLowerCase() == category.toLowerCase())
          .toList();
    }

    emit(StudentCoursesLoaded(filteredCourses));
  }
}
