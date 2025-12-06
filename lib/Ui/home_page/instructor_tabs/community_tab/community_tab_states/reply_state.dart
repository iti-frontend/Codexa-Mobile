import 'package:codexa_mobile/Domain/entities/community_entity.dart';

abstract class ReplyState {}

class ReplyInitial extends ReplyState {}

class ReplyLoading extends ReplyState {}

class ReplyAdded extends ReplyState {
  final String postId;
  final String commentId;
  final CommentsEntity newReply;

  ReplyAdded(
      {required this.postId, required this.commentId, required this.newReply});
}

class ReplyError extends ReplyState {
  final String message;
  ReplyError(this.message);
}
