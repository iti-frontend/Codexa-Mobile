import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Domain/entities/add_course_entity.dart';
import 'package:codexa_mobile/Domain/usecases/courses/add_course_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/delete_course_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/get_courses_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/courses/update_course_usecase.dart';
import 'upload_instructor_courses_state.dart';

class InstructorUploadCoursesCubit extends Cubit<InstructorCoursesState> {
  final GetCoursesUseCase getCoursesUseCase;
  final AddCourseUseCase addCourseUseCase;
  final UpdateCourseUseCase updateCourseUseCase;
  final DeleteCourseUseCase deleteCourseUseCase;

  InstructorUploadCoursesCubit({
    required this.getCoursesUseCase,
    required this.addCourseUseCase,
    required this.updateCourseUseCase,
    required this.deleteCourseUseCase,
  }) : super(InstructorCoursesInitial());

  Future<void> fetchCourses() async {
    emit(InstructorCoursesLoading());
    final result = await getCoursesUseCase.instructorUploadCall();
    result.fold(
      (failure) => emit(InstructorCoursesError(failure.errorMessage)),
      (courses) => emit(InstructorCoursesLoaded(courses)),
    );
  }

  Future<void> addCourse(CourseInstructorEntity course) async {
    emit(InstructorCoursesLoading());
    final result = await addCourseUseCase.call(course);
    result.fold(
      (failure) => emit(CourseOperationError(failure.errorMessage)),
      (_) => emit(CourseOperationSuccess('Course added successfully')),
    );
    await fetchCourses();
  }

  Future<void> updateCourse(CourseInstructorEntity course) async {
    emit(InstructorCoursesLoading());
    final result = await updateCourseUseCase.call(course);
    result.fold(
      (failure) => emit(CourseOperationError(failure.errorMessage)),
      (_) => emit(CourseOperationSuccess('Course updated successfully')),
    );
    await fetchCourses();
  }

  Future<void> deleteCourse(String id) async {
    if (id.isEmpty) {
      print('Error: course id is empty!');
      return;
    }

    emit(InstructorCoursesLoading());
    final result = await deleteCourseUseCase.call(id);
    result.fold(
      (failure) {
        print('Delete failed: ${failure.errorMessage}');
        emit(CourseOperationError(failure.errorMessage));
      },
      (_) {
        print('Course deleted successfully'); // Debug print
        emit(CourseOperationSuccess('Course deleted successfully'));
      },
    );
    await fetchCourses();
  }
}
