import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/Domain/usecases/community/get_all_posts_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/create_post_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/delete_post_usecase.dart';

import '../community_tab_states/posts_state.dart';

class CommunityPostsCubit extends Cubit<CommunityPostsState> {
  final GetAllPostsUseCase getAllPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final DeletePostUseCase deletePostUseCase;

  CommunityPostsCubit({
    required this.getAllPostsUseCase,
    required this.createPostUseCase,
    required this.deletePostUseCase,
  }) : super(CommunityPostsInitial());

  Future<void> fetchPosts() async {
    emit(CommunityPostsLoading());
    final result = await getAllPostsUseCase();
    result.fold(
          (failure) => emit(CommunityPostsError(failure.errorMessage)),
          (posts) => emit(CommunityPostsLoaded(posts)),
    );
  }

  Future<void> createPost({
    required String content,
    String? image,
    dynamic linkUrl,
    List<dynamic>? attachments,
  }) async {
    emit(CommunityPostsLoading());
    final result = await createPostUseCase(
      content: content,
      image: image,
      linkUrl: linkUrl,
      attachments: attachments,
    );

    result.fold(
          (failure) => emit(PostOperationError(failure.errorMessage)),
          (_) => emit(PostOperationSuccess("Post created successfully")),
    );

    await fetchPosts(); // refresh
  }

  Future<void> deletePost(String postId) async {
    emit(CommunityPostsLoading());
    final result = await deletePostUseCase(postId);

    result.fold(
          (failure) => emit(PostOperationError(failure.errorMessage)),
          (_) => emit(PostOperationSuccess("Post deleted successfully")),
    );

    await fetchPosts();
  }

  void updatePost(CommunityEntity updatedPost) {
    if (state is CommunityPostsLoaded) {
      final currentPosts = (state as CommunityPostsLoaded).posts;
      final index = currentPosts.indexWhere((p) => p.id == updatedPost.id);
      if (index != -1) {
        final newPosts = List<CommunityEntity>.from(currentPosts);
        newPosts[index] = updatedPost;
        emit(CommunityPostsLoaded(newPosts));
      }
    }
  }
}
