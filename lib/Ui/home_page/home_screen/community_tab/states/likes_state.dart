abstract class LikeState {}

class LikeInitial extends LikeState {}

class LikeLoading extends LikeState {}

class LikeSuccess extends LikeState {}

class LikeError extends LikeState {
  final String message;
  LikeError(this.message);
}
