// lib/src/ui/courses/student_courses_cubit.dart

import 'package:codexa_mobile/Data/models/courses_dto.dart';
import 'package:codexa_mobile/Domain/entities/courses_entity.dart';
import 'package:codexa_mobile/Domain/usecases/courses/get_courses_usecase.dart';
import 'package:codexa_mobile/Ui/home_page/student_tabs/courses_tab/courses_cubit/courses_student_states.dart';
import 'package:codexa_mobile/Domain/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentCoursesCubit extends Cubit<StudentCoursesState> {
  final GetCoursesUseCase getStudentCoursesUseCase;

  List<CourseEntity> allCourses = [];
  List<CourseEntity> filteredCourses = [];

  StudentCoursesCubit(this.getStudentCoursesUseCase)
      : super(
          StudentCoursesInitial(),
        );

  Future<void> fetchCourses() async {
    print('DEBUG: StudentCoursesCubit.fetchCourses called');
    emit(StudentCoursesLoading());
    final result = await getStudentCoursesUseCase();
    result.fold(
      (failure) {
        print('DEBUG: StudentCoursesCubit Error: ${failure.errorMessage}');
        emit(StudentCoursesError(failure.errorMessage));
      },
      (courses) {
        print('DEBUG: StudentCoursesCubit Loaded: ${courses.length} courses');
        allCourses = courses;
        filteredCourses = courses;
        emit(StudentCoursesLoaded(filteredCourses));
      },
    );
  }

  /// Fetch courses and merge with favourites from backend
  Future<void> fetchCoursesWithFavourites(
      Future<Either<Failures, List<CourseEntity>>> Function(
              {int page, int limit})
          getFavouritesUseCase) async {
    print('🔵 [COURSES_CUBIT] fetchCoursesWithFavourites called');
    emit(StudentCoursesLoading());

    // Fetch all courses
    final coursesResult = await getStudentCoursesUseCase();

    await coursesResult.fold(
      (failure) async {
        print(
            '🔴 [COURSES_CUBIT] Error fetching courses: ${failure.errorMessage}');
        emit(StudentCoursesError(failure.errorMessage));
      },
      (courses) async {
        print('🟢 [COURSES_CUBIT] Fetched ${courses.length} courses');

        // Fetch favourites to get IDs
        final favouritesResult =
            await getFavouritesUseCase(page: 1, limit: 100);

        favouritesResult.fold(
          (failure) {
            print(
                '🟡 [COURSES_CUBIT] Could not fetch favourites: ${failure.errorMessage}');
            // Continue with courses without favourite state
            allCourses = courses;
            filteredCourses = courses;
            emit(StudentCoursesLoaded(filteredCourses));
          },
          (favourites) {
            print('🟢 [COURSES_CUBIT] Fetched ${favourites.length} favourites');

            // Extract favourite IDs
            final favouriteIds =
                favourites.map((c) => c.id).whereType<String>().toSet();
            print('🔵 [COURSES_CUBIT] Favourite IDs: $favouriteIds');

            // Merge: Update courses with favourite state
            allCourses = courses.map((course) {
              final isFav = favouriteIds.contains(course.id);
              return course.copyWith(isFavourite: isFav);
            }).toList();

            filteredCourses = List.from(allCourses);

            final favCount =
                allCourses.where((c) => c.isFavourite == true).length;
            print(
                '🟢 [COURSES_CUBIT] Merged! Total: ${allCourses.length}, Favourites: $favCount');

            emit(StudentCoursesLoaded(filteredCourses));
          },
        );
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
      filteredCourses = List.from(allCourses);
    } else {
      filteredCourses = allCourses
          .where((course) =>
              course.category?.toLowerCase() == category.toLowerCase())
          .toList();
    }

    emit(StudentCoursesLoaded(filteredCourses));
  }

  void updateCourseFavourite(String courseId, bool isFavourite) {
    print(
        '🔵 StudentCoursesCubit: Updating courseId: $courseId to isFavourite: $isFavourite');

    // Update in allCourses
    final allIndex = allCourses.indexWhere((c) => c.id == courseId);
    if (allIndex != -1) {
      print('🟢 Found course in allCourses at index $allIndex');
      final course = allCourses[allIndex];
      allCourses[allIndex] = CoursesDto(
        id: course.id,
        title: course.title,
        description: course.description,
        price: course.price,
        category: course.category,
        level: course.level,
        instructor: course.instructor,
        enrolledStudents: course.enrolledStudents,
        videos: course.videos,
        progress: course.progress,
        createdAt: course.createdAt,
        updatedAt: course.updatedAt,
        v: course.v,
        isFavourite: isFavourite,
      );
    } else {
      print('🔴 Course NOT found in allCourses');
    }

    // Update in filteredCourses
    final filteredIndex = filteredCourses.indexWhere((c) => c.id == courseId);
    if (filteredIndex != -1) {
      print('🟢 Found course in filteredCourses at index $filteredIndex');
      final course = filteredCourses[filteredIndex];
      filteredCourses[filteredIndex] = CoursesDto(
        id: course.id,
        title: course.title,
        description: course.description,
        price: course.price,
        category: course.category,
        level: course.level,
        instructor: course.instructor,
        enrolledStudents: course.enrolledStudents,
        videos: course.videos,
        progress: course.progress,
        createdAt: course.createdAt,
        updatedAt: course.updatedAt,
        v: course.v,
        isFavourite: isFavourite,
      );
    } else {
      print('🔴 Course NOT found in filteredCourses');
    }

    // Emit new state to trigger UI rebuild
    print(
        '🟢 Emitting StudentCoursesLoaded with ${filteredCourses.length} courses');
    emit(StudentCoursesLoaded(List.from(filteredCourses)));
  }

  /// Reset cubit state - call this on logout
  void reset() {
    allCourses.clear();
    filteredCourses.clear();
    emit(StudentCoursesInitial());
  }
}
