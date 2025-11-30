abstract class ToggleFavouriteState {}

class ToggleFavouriteInitial extends ToggleFavouriteState {}

class ToggleFavouriteLoading extends ToggleFavouriteState {}

class ToggleFavouriteSuccess extends ToggleFavouriteState {
  final String courseId;
  final bool isFavourite;

  ToggleFavouriteSuccess(this.courseId, this.isFavourite);
}

class ToggleFavouriteError extends ToggleFavouriteState {
  final String courseId;
  final String message;

  ToggleFavouriteError(this.courseId, this.message);
}
