import 'package:codexa_mobile/Domain/entities/community/comment_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'community_states.dart';
import 'package:codexa_mobile/Domain/usecases/community/get_all_posts_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/create_post_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/toggle_like_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/add_comment_usecase.dart';
import 'package:codexa_mobile/Domain/entities/community/community_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:codexa_mobile/Domain/failures.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final GetAllPostsUseCase getAllPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final ToggleLikeUseCase toggleLikeUseCase;
  final AddCommentUseCase addCommentUseCase;

  CommunityCubit({
    required this.getAllPostsUseCase,
    required this.createPostUseCase,
    required this.toggleLikeUseCase,
    required this.addCommentUseCase,
  }) : super(CommunityInitial());

  Future<void> fetchPosts() async {
    emit(CommunityLoading());
    final result = await getAllPostsUseCase.call();
    result.fold(
      (failure) => emit(CommunityError(_failureMessage(failure))),
      (posts) => emit(CommunityLoaded(posts)),
    );
  }

  String _failureMessage(Failures f) => f.toString();

  /// Optimistic toggle like: update UI immediately, call backend, revert on failure.
  Future<void> toggleLikeOptimistic(String postId, String currentUserId) async {
    final stateSnapshot = state;
    if (state is! CommunityLoaded) return;

    final posts = List<CommunityEntity>.from((state as CommunityLoaded).posts);
    final idx = posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;

    final post = posts[idx];

    // clone likes
    final likes = List<String>.from(post.likes ?? []);
    final hadLiked = likes.contains(currentUserId);

    if (hadLiked) {
      likes.remove(currentUserId);
    } else {
      likes.insert(0, currentUserId); // put current user first
    }

    // build new post copy (keep other fields)
    final updatedPost = CommunityEntity(
      id: post.id,
      author: post.author,
      authorType: post.authorType,
      type: post.type,
      content: post.content,
      image: post.image,
      linkUrl: post.linkUrl,
      attachments: post.attachments,
      poll: post.poll,
      likes: likes,
      comments: post.comments,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
      v: post.v,
    );

    posts[idx] = updatedPost;

    // emit optimistic state
    emit(CommunityLoaded(posts));

    // call backend
    final res = await toggleLikeUseCase.call(postId);
    res.fold(
      (failure) {
        // revert
        emit(stateSnapshot);
        emit(CommunityError(_failureMessage(failure)));
      },
      (_) {
        // success: optionally refetch or keep optimistic state
      },
    );
  }

  /// Optimistic add comment: append comment locally then call backend.
  Future<void> addCommentOptimistic(
      String postId,
      String text,
      String currentUserId,
      String currentUserName,
      String currentUserImage) async {
    final stateSnapshot = state;
    if (state is! CommunityLoaded) return;

    final posts = List<CommunityEntity>.from((state as CommunityLoaded).posts);
    final idx = posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final post = posts[idx];

    // create a temporary comment
    final tempComment = CommunityCommentEntity(
      id: 'tmp-${DateTime.now().millisecondsSinceEpoch}',
      authorName: currentUserName,
      authorImage: currentUserImage,
      content: text,
    );

    final updatedComments =
        List<CommunityCommentEntity>.from(post.comments ?? []);
    updatedComments.add(tempComment);

    final updatedPost = CommunityEntity(
      id: post.id,
      author: post.author,
      authorType: post.authorType,
      type: post.type,
      content: post.content,
      image: post.image,
      linkUrl: post.linkUrl,
      attachments: post.attachments,
      poll: post.poll,
      likes: post.likes,
      comments: updatedComments,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
      v: post.v,
    );

    posts[idx] = updatedPost;
    emit(CommunityLoaded(posts));

    // call backend
    final res = await addCommentUseCase.call(postId, text);
    res.fold(
      (failure) {
        // revert
        emit(stateSnapshot);
        emit(CommunityError(_failureMessage(failure)));
      },
      (updatedPostDto) async {
        // backend returns full post — better to replace local post with backend version
        // fetch fresh posts to sync (or replace single post if returned)
        await fetchPosts();
      },
    );
  }
}
