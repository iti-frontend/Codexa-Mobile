import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_states/comment_state.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_states/likes_state.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/comment_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/likes_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/posts_cubit.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:provider/provider.dart';

/// PostDetailsScreen (complete, ready to paste)
/// - Prevents keyboard overflow by constraining media height
/// - Comments list is inside Expanded (ListView)
/// - Fixed bottom input bar that respects keyboard inset
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

  @override
  void initState() {
    super.initState();
    _comments = widget.post.comments ?? [];
  }

  @override
  void dispose() {
    _commentController.dispose();
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
        const SnackBar(content: Text("Error adding comment")),
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
      return UserEntity(id: "unknown", name: "Unknown");
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      return timeago.format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  String? _getCurrentUserIdSafe(BuildContext context) {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final u = userProvider.user;
      if (u is Map) return (u['_id'] ?? u['id'])?.toString();
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final theme = Theme.of(context);
    final maxImageHeight = MediaQuery.of(context).size.height * .35;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.iconTheme.color,
        automaticallyImplyLeading: false,
        title: Text(
          "Post",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.iconTheme.color,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: theme.iconTheme.color),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                /// POST HEADER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Author Row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  theme.dividerColor.withOpacity(0.1),
                              backgroundImage: post.author?.profileImage != null
                                  ? NetworkImage(post.author!.profileImage!)
                                  : null,
                              child: post.author?.profileImage == null
                                  ? Icon(Icons.person_outline,
                                      color: theme.dividerTheme.color)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post.author?.name ?? "Unknown",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.iconTheme.color,
                                        fontSize: 15,
                                      )),
                                  const SizedBox(height: 4),
                                  Text(_formatTime(post.createdAt),
                                      style: TextStyle(
                                          color: theme.dividerTheme.color
                                              ?.withOpacity(0.7),
                                          fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// Post text
                        if (post.content != null)
                          Text(
                            post.content!,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: theme.iconTheme.color,
                            ),
                          ),

                        const SizedBox(height: 12),

                        /// IMAGE (auto scaled)
                        if (post.image != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxHeight: maxImageHeight),
                              child: Image.network(post.image!,
                                  fit: BoxFit.cover, width: double.infinity),
                            ),
                          ),

                        const SizedBox(height: 14),

                        /// Likes + Comments buttons
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: theme.dividerColor.withOpacity(0.1),
                                width: 1,
                              ),
                              bottom: BorderSide(
                                color: theme.dividerColor.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _ReactionButton(
                                icon: Icons.thumb_up_alt_rounded,
                                active: post.likes?.any((l) =>
                                        l.user ==
                                        _getCurrentUserIdSafe(context)) ??
                                    false,
                                label: "${post.likes?.length ?? 0}",
                                colorActive: theme.progressIndicatorTheme.color,
                                colorInactive: theme.dividerTheme.color,
                                textColor: theme.iconTheme.color,
                                onTap: () {
                                  if (post.id != null) {
                                    context
                                        .read<LikeCubit>()
                                        .toggleLike(post.id!);
                                  }
                                },
                              ),
                              _ReactionButton(
                                icon: Icons.comment_rounded,
                                label: "${_comments.length}",
                                textColor: theme.iconTheme.color,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          "Comments",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: theme.iconTheme.color,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                /// COMMENTS LIST
                BlocListener<LikeCubit, LikeState>(
                  listener: (context, state) {
                    if (state is LikeSuccess) {
                      // Refresh post to update like count
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
                        context
                            .read<CommunityPostsCubit>()
                            .updatePost(widget.post);
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
                              child: Text("Be first to comment",
                                  style: TextStyle(
                                      color: theme.dividerTheme.color)),
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final c = _comments[i];
                            final isMine =
                                c.user?.id == _getCurrentUserIdSafe(context);

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.cardTheme.color,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.dividerColor.withOpacity(0.1),
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          theme.dividerColor.withOpacity(0.1),
                                      backgroundImage: c.user?.profileImage !=
                                              null
                                          ? NetworkImage(c.user!.profileImage!)
                                          : null,
                                      child: c.user?.profileImage == null
                                          ? Icon(Icons.person_outline,
                                              size: 16,
                                              color: theme.dividerTheme.color)
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                c.user?.name ?? "Unknown",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.iconTheme.color,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _formatTime(c.createdAt),
                                                style: TextStyle(
                                                    color: theme
                                                        .dividerTheme.color
                                                        ?.withOpacity(0.7),
                                                    fontSize: 11),
                                              ),
                                              const Spacer(),
                                              if (isMine)
                                                GestureDetector(
                                                  onTap: () {
                                                    if (c.id != null) {
                                                      context
                                                          .read<CommentCubit>()
                                                          .deleteComment(
                                                            widget.post.id!,
                                                            c.id!,
                                                          );
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Icon(
                                                        Icons.delete_outline,
                                                        size: 16,
                                                        color: Colors.red),
                                                  ),
                                                )
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            c.text ?? '',
                                            style: TextStyle(
                                              fontSize: 13,
                                              height: 1.4,
                                              color: theme.iconTheme.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: _comments.length,
                        ),
                      );
                    },
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 90)),
              ],
            ),
          ),

          /// COMMENT INPUT FIXED AT BOTTOM
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 6,
                    offset: const Offset(0, -1),
                  )
                ],
              ),
              child: Row(
                children: [
                  /// User avatar
                  _userAvatar(),

                  const SizedBox(width: 10),

                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      maxLines: null,
                      style: TextStyle(
                        color: theme.iconTheme.color,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: "Write a comment...",
                        hintStyle: TextStyle(
                          color: theme.dividerTheme.color?.withOpacity(0.6),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: theme.dividerColor.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: theme.dividerColor.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: theme.progressIndicatorTheme.color ??
                                Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: _isAddingComment ? null : _addComment,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.progressIndicatorTheme.color,
                        shape: BoxShape.circle,
                      ),
                      child: _isAddingComment
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.send_rounded,
                              size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userAvatar() {
    try {
      final u = Provider.of<UserProvider>(context, listen: false).user;
      final img = (u is Map) ? u["profileImage"] as String? : null;

      return CircleAvatar(
        radius: 22,
        backgroundImage: img != null ? NetworkImage(img) : null,
        child: img == null
            ? Icon(Icons.person_outline,
                color: Theme.of(context).dividerTheme.color)
            : null,
      );
    } catch (_) {
      return CircleAvatar(
        radius: 22,
        child: Icon(Icons.person_outline,
            color: Theme.of(context).dividerTheme.color),
      );
    }
  }
}

/// Reusable reaction button - theme-aware
class _ReactionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final bool active;
  final VoidCallback? onTap;

  final Color? colorActive;
  final Color? colorInactive;
  final Color? textColor;

  const _ReactionButton({
    required this.icon,
    this.label,
    this.onTap,
    this.active = false,
    this.colorActive,
    this.colorInactive,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = active
        ? (colorActive ?? theme.progressIndicatorTheme.color)
        : (colorInactive ?? theme.dividerTheme.color);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 19, color: iconColor),
          if (label != null) ...[
            const SizedBox(width: 5),
            Text(
              label!,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textColor ?? theme.iconTheme.color),
            )
          ]
        ],
      ),
    );
  }
}
