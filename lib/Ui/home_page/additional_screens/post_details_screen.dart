import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/states/comment_state.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/states/likes_state.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/cubits/comment_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/cubits/likes_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/cubits/posts_cubit.dart';
import 'package:provider/provider.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;
import 'package:codexa_mobile/localization/localization_service.dart';

// Widget imports
import 'widgets/post_header_section.dart';
import 'widgets/post_reactions_bar.dart';
import 'widgets/comment_item.dart';
import 'widgets/comment_input_field.dart';

/// PostDetailsScreen with RTL support and translations
class PostDetailsScreen extends StatefulWidget {
  final CommunityEntity post;

  const PostDetailsScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  late List<CommentsEntity> _comments;
  bool _isAddingComment = false;
  late LocalizationService _localizationService;
  late generated.S _translations;

  @override
  void initState() {
    super.initState();
    _comments = widget.post.comments ?? [];
    _initializeLocalization();
  }

  void _initializeLocalization() {
    _localizationService = LocalizationService();
    _translations = generated.S(_localizationService.locale);
    _localizationService.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {
        _translations = generated.S(_localizationService.locale);
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _localizationService.removeListener(_onLocaleChanged);
    super.dispose();
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || widget.post.id == null) return;
    setState(() => _isAddingComment = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final dynamic userJson = userProvider.user;
      final currentUser = _mapUserJsonToEntity(userJson);

      await context.read<CommentCubit>().addComment(
            widget.post.id!,
            text,
            currentUser,
          );
    } catch (_) {
      setState(() => _isAddingComment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_translations.errorAddingComment)),
      );
    }
  }

  UserEntity _mapUserJsonToEntity(dynamic userJson) {
    if (userJson is Map<String, dynamic>) {
      return UserEntity(
        id: (userJson['_id'] ?? userJson['id'])?.toString(),
        name: (userJson['name'] ?? userJson['fullName'])?.toString(),
        profileImage: userJson['profileImage']?.toString(),
      );
    }
    // If it's already a proper object
    try {
      return UserEntity(
        id: userJson?.id?.toString(),
        name: userJson?.name?.toString(),
        profileImage: userJson?.profileImage?.toString(),
      );
    } catch (_) {
      return UserEntity(id: "unknown", name: _translations.unknown);
    }
  }

  /// Get the current logged-in user's ID safely.
  String? _getCurrentUserIdSafe(BuildContext context) {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      if (user is StudentEntity) {
        return user.id;
      } else if (user is InstructorEntity) {
        return user.id;
      } else if (user is Map<String, dynamic>) {
        return (user['_id'] ?? user['id'])?.toString();
      } else if (user != null) {
        try {
          return (user as dynamic).id?.toString();
        } catch (_) {
          return null;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final theme = Theme.of(context);
    final isRTL = _localizationService.isRTL();

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(theme, isRTL),
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  /// POST HEADER
                  SliverToBoxAdapter(
                    child: PostHeaderSection(
                      post: post,
                      localizationService: _localizationService,
                      translations: _translations,
                    ),
                  ),

                  /// REACTIONS BAR
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PostReactionsBar(
                        likesCount: post.likes?.length ?? 0,
                        commentsCount: _comments.length,
                        isLiked: post.likes?.any((l) =>
                                l.user == _getCurrentUserIdSafe(context)) ??
                            false,
                        onLikeTap: () {
                          if (post.id != null) {
                            context.read<LikeCubit>().toggleLike(post.id!);
                          }
                        },
                        isRTL: isRTL,
                      ),
                    ),
                  ),

                  /// COMMENTS HEADER
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _translations.comments,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: theme.iconTheme.color,
                        ),
                        textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      ),
                    ),
                  ),

                  /// COMMENTS LIST
                  _buildCommentsList(theme, isRTL),

                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
                ],
              ),
            ),

            /// COMMENT INPUT
            CommentInputField(
              controller: _commentController,
              isLoading: _isAddingComment,
              onSend: _addComment,
              isRTL: isRTL,
              translations: _translations,
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(ThemeData theme, bool isRTL) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      foregroundColor: theme.iconTheme.color,
      automaticallyImplyLeading: false,
      title: Text(
        _translations.post,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: theme.iconTheme.color,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isRTL ? Icons.arrow_forward : Icons.close,
            color: theme.iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildCommentsList(ThemeData theme, bool isRTL) {
    return BlocListener<LikeCubit, LikeState>(
      listener: (context, state) {
        if (state is LikeSuccess) {
          context.read<CommunityPostsCubit>().fetchPosts();
        }
      },
      child: BlocConsumer<CommentCubit, CommentState>(
        listener: (context, state) {
          if (state is CommentAdded) {
            setState(() {
              _comments.add(state.newComment);
              widget.post.comments = _comments;
              _commentController.clear();
              _isAddingComment = false;
            });
            context.read<CommunityPostsCubit>().updatePost(widget.post);
          } else if (state is CommentDeleted) {
            setState(() {
              _comments.removeWhere((c) => c.id == state.commentId);
            });
          }
        },
        builder: (context, _) {
          if (_comments.isEmpty) {
            return SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    _translations.beFirstToComment,
                    style: TextStyle(
                      color: theme.dividerTheme.color,
                    ),
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  ),
                ),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final c = _comments[i];
                final currentUserId = _getCurrentUserIdSafe(context);
                final commentUserId = c.user?.id;
                final isMine = commentUserId == currentUserId;

                return CommentItem(
                  comment: c,
                  isMine: isMine,
                  onDelete: () {
                    if (c.id != null) {
                      context.read<CommentCubit>().deleteComment(
                            widget.post.id!,
                            c.id!,
                          );
                    }
                  },
                  localizationService: _localizationService,
                  translations: _translations,
                );
              },
              childCount: _comments.length,
            ),
          );
        },
      ),
    );
  }
}
