import 'package:codexa_mobile/Domain/entities/community_entity.dart';

abstract class CommunityPostsState {}

class CommunityPostsInitial extends CommunityPostsState {}

class CommunityPostsLoading extends CommunityPostsState {}

class CommunityPostsLoaded extends CommunityPostsState {
  final List<CommunityEntity> posts;

  CommunityPostsLoaded(this.posts);
}

class CommunityPostsError extends CommunityPostsState {
  final String message;

  CommunityPostsError(this.message);
}

class PostOperationSuccess extends CommunityPostsState {
  final String message;

  PostOperationSuccess(this.message);
}

class PostOperationError extends CommunityPostsState {
  final String message;

  PostOperationError(this.message);
}
