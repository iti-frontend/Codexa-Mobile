import 'package:codexa_mobile/Domain/entities/community_entity.dart';

abstract class CommentState {}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentAdded extends CommentState {
  final String postId;
  final CommentsEntity newComment;

  CommentAdded({required this.postId, required this.newComment});
}

class CommentDeleted extends CommentState {
  final String commentId;
  CommentDeleted(this.commentId);
}

class CommentError extends CommentState {
  final String message;
  CommentError(this.message);
}
