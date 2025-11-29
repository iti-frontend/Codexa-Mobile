import 'package:codexa_mobile/Domain/entities/courses_entity.dart';

abstract class FavouritesState {}

class FavouritesInitial extends FavouritesState {}

class FavouritesLoading extends FavouritesState {}

class FavouritesLoaded extends FavouritesState {
  final List<CourseEntity> courses;
  final bool hasReachedMax;

  FavouritesLoaded(this.courses, {this.hasReachedMax = false});
}

class FavouritesEmpty extends FavouritesState {}

class FavouritesError extends FavouritesState {
  final String message;

  FavouritesError(this.message);
}
