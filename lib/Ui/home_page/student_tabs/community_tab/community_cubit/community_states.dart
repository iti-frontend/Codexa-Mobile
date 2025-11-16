import 'package:codexa_mobile/Domain/entities/community/community_entity.dart';

abstract class CommunityState {}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class CommunityLoaded extends CommunityState {
  final List<CommunityEntity> posts;

  CommunityLoaded(this.posts);
}

class CommunityError extends CommunityState {
  final String message;

  CommunityError(this.message);
}

class CommunityActionSuccess extends CommunityState {
  final String message;
  CommunityActionSuccess(this.message);
}