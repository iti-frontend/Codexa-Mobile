import 'package:codexa_mobile/Domain/entities/courses_entity.dart';

abstract class StudentCoursesState {}

class StudentCoursesInitial extends StudentCoursesState {}

class StudentCoursesLoading extends StudentCoursesState {}

class StudentCoursesLoaded extends StudentCoursesState {
  final List<CourseEntity> courses;
  StudentCoursesLoaded(this.courses);
}

class StudentCoursesError extends StudentCoursesState {
  final String message;
  StudentCoursesError(this.message);
}
