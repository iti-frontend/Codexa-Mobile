import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codexa_mobile/Domain/usecases/community/get_all_posts_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/create_post_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/toggle_like_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/add_comment_usecase.dart';
import 'package:codexa_mobile/Domain/usecases/community/add_reply_usecase.dart';
import 'community_states.dart';
import 'package:codexa_mobile/Domain/entities/community/community_entity.dart';
import 'package:codexa_mobile/Domain/entities/community/comment_entity.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final GetAllPostsUseCase getAllPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final ToggleLikeUseCase toggleLikeUseCase;
  final AddCommentUseCase addCommentUseCase;
  final AddReplyUseCase addReplyUseCase;

  CommunityCubit({
    required this.getAllPostsUseCase,
    required this.createPostUseCase,
    required this.toggleLikeUseCase,
    required this.addCommentUseCase,
    required this.addReplyUseCase,
  }) : super(CommunityInitial());

  Future<void> fetchPosts() async {
    emit(CommunityLoading());
    final result = await getAllPostsUseCase.call();
    result.fold(
      (failure) => emit(CommunityError(failure.toString())),
      (posts) => emit(CommunityLoaded(posts)),
    );
  }

  Future<void> createPost(Map<String, dynamic> body) async {
    final result = await createPostUseCase.call(body);
    result.fold(
      (failure) => emit(CommunityError(failure.toString())),
      (post) {
        if (state is CommunityLoaded) {
          final currentPosts = List<CommunityEntity>.from((state as CommunityLoaded).posts);
          currentPosts.insert(0, post);
          emit(CommunityLoaded(currentPosts));
        } else {
          emit(CommunityLoaded([post]));
        }
      },
    );
  }


  Future<void> toggleLike(String postId, String currentUserId) async {
    if (state is CommunityLoaded) {
      final posts = List<CommunityEntity>.from((state as CommunityLoaded).posts);
      final index = posts.indexWhere((p) => p.id == postId);
      if (index == -1) return;

      final post = posts[index];
      final previousLikes = List<String>.from(post.likes ?? []);

      // Optimistic update
      final likes = List<String>.from(post.likes ?? []);
      if (likes.contains(currentUserId)) {
        likes.remove(currentUserId);
      } else {
        likes.add(currentUserId);
      }

      posts[index] = CommunityEntity(
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

      emit(CommunityLoaded(posts));

      final result = await toggleLikeUseCase.call(postId);
      result.fold(
        (failure) {
          posts[index] = CommunityEntity(
            id: post.id,
            author: post.author,
            authorType: post.authorType,
            type: post.type,
            content: post.content,
            image: post.image,
            linkUrl: post.linkUrl,
            attachments: post.attachments,
            poll: post.poll,
            likes: previousLikes,
            comments: post.comments,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            v: post.v,
          );
          emit(CommunityLoaded(posts));
        },
        (updatedPost) {
          final idx = posts.indexWhere((p) => p.id == updatedPost);
          if (idx != -1) {
            posts[idx] = updatedPost as CommunityEntity;
            emit(CommunityLoaded(posts));
          }
        },
      );
    }
  }

  Future<void> addComment(String postId, String text) async {
    if (state is CommunityLoaded) {
      final posts = List<CommunityEntity>.from((state as CommunityLoaded).posts);
      final index = posts.indexWhere((p) => p.id == postId);
      if (index == -1) return;

      final post = posts[index];
      final previousComments = List<CommunityCommentEntity>.from(post.comments ?? []);

      final tempComment = CommunityCommentEntity(
        id: "temp_${DateTime.now().millisecondsSinceEpoch}",
        authorName: "You",
        authorImage: null,
        content: text,
      );

      final updatedComments = [...previousComments, tempComment];

      posts[index] = CommunityEntity(
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

      emit(CommunityLoaded(posts));

      final result = await addCommentUseCase.call(postId,  text);
      result.fold(
        (failure) {
          posts[index] = CommunityEntity(
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
            comments: previousComments,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            v: post.v,
          );
          emit(CommunityLoaded(posts));
        },
        (updatedPost) {
          posts[index] = updatedPost;
          emit(CommunityLoaded(posts));
        },
      );
    }
  }

  Future<void> addReply(String postId, String commentId, String text) async {
    if (state is CommunityLoaded) {
      final posts = List<CommunityEntity>.from((state as CommunityLoaded).posts);
      final index = posts.indexWhere((p) => p.id == postId);
      if (index == -1) return;

      final result = await addReplyUseCase.call(postId, commentId, text);
      result.fold(
        (failure) => emit(CommunityError(failure.toString())),
        (updatedPost) {
          posts[index] = updatedPost;
          emit(CommunityLoaded(posts));
        },
      );
    }
  }
}
