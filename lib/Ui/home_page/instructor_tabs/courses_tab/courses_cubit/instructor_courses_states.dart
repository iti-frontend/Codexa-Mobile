import 'package:codexa_mobile/Domain/entities/courses_entity.dart';

abstract class InstructorCoursesStates {}

class InstructorCoursesInitialState extends InstructorCoursesStates {}

class InstructorCoursesLoadingState extends InstructorCoursesStates {}

class InstructorCoursesSuccessState extends InstructorCoursesStates {
  final List<CourseEntity> courses;

  InstructorCoursesSuccessState(this.courses);
}

class InstructorCoursesErrorState extends InstructorCoursesStates {
  final String error;

  InstructorCoursesErrorState(this.error);
}
