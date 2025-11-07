import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Domain/usecases/courses/get_my_courses_usecase.dart';
import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Domain/failures.dart';

part 'my_courses_state.dart';

class MyCoursesCubit extends Cubit<MyCoursesState> {
  final GetMyCoursesUseCase getMyCoursesUseCase;

  MyCoursesCubit(this.getMyCoursesUseCase) : super(MyCoursesInitial());

  Future<void> fetchMyCourses(String token) async {
    emit(MyCoursesLoading());
    final result = await getMyCoursesUseCase(token);
    result.fold(
      (failure) => emit(MyCoursesError(failure.errorMessage)),
      (courses) => emit(MyCoursesLoaded(courses)),
    );
  }
}
