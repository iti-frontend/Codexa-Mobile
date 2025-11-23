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

      // Clearing and UI update handled in CommentAdded listener below
    } catch (e) {
      setState(() => _isAddingComment = false);
      debugPrint('Error adding comment: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error adding comment')));
    }
  }

  UserEntity _mapUserJsonToEntity(dynamic userJson) {
    try {
      if (userJson is Map<String, dynamic>) {
        return UserEntity(
          id: (userJson['_id'] ?? userJson['id'])?.toString(),
          name: (userJson['name'] ?? userJson['fullName'])?.toString(),
          profileImage: userJson['profileImage']?.toString(),
        );
      }
    } catch (_) {}
    return UserEntity(id: 'currentUserId', name: 'You', profileImage: null);
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return timeago.format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String? _getCurrentUserIdSafe(BuildContext context) {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final dynamic userJson = userProvider.user;
      // Relaxed check to Map
      if (userJson is Map) {
        return (userJson['_id'] ?? userJson['id'])?.toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    // Constrain image to a fraction of screen to avoid overflow when keyboard opens
    final double maxImageHeight = MediaQuery.of(context).size.height * 0.35;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title:
            const Text('Post', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Post header and content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundImage: post.author?.profileImage != null
                                  ? NetworkImage(post.author!.profileImage!)
                                  : null,
                              child: post.author?.profileImage == null
                                  ? const Icon(Icons.person_outline, size: 26)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post.author?.name ?? 'Unknown',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(_formatTime(post.createdAt),
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            IconButton(
                                icon: const Icon(Icons.more_horiz),
                                onPressed: () {},
                                splashRadius: 20),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Content
                        if (post.content != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(post.content!,
                                style:
                                    const TextStyle(fontSize: 15, height: 1.5)),
                          ),

                        // Media with constrained height
                        if (post.image != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxHeight: maxImageHeight),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.network(post.image!,
                                      fit: BoxFit.cover,
                                      width: double.infinity),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Reaction row
                        Row(
                          children: [
                            _ReactionButton(
                              icon: Icons.thumb_up_alt_rounded,
                              active: post.likes?.any((l) =>
                                      l.user ==
                                      _getCurrentUserIdSafe(context)) ??
                                  false,
                              label: '${post.likes?.length ?? 0}',
                              onTap: () {
                                if (post.id != null) {
                                  context
                                      .read<LikeCubit>()
                                      .toggleLike(post.id!);
                                  context
                                      .read<CommunityPostsCubit>()
                                      .fetchPosts();
                                }
                              },
                            ),
                            const SizedBox(width: 12),
                            _ReactionButton(
                              icon: Icons.comment_rounded,
                              label: '${_comments.length}',
                              onTap: () {},
                            ),
                            const Spacer(),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.share_outlined)),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Section title
                        Text('Comments',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800)),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // Comments list
                BlocConsumer<CommentCubit, CommentState>(
                  listener: (context, state) {
                    try {
                      if (state is CommentAdded && state.newComment != null) {
                        setState(() {
                          _comments = [..._comments, state.newComment!];
                          widget.post.comments = _comments;
                          _isAddingComment = false;
                          _commentController.clear();
                        });
                        context
                            .read<CommunityPostsCubit>()
                            .updatePost(widget.post);
                        context.read<CommunityPostsCubit>().fetchPosts();
                      } else if (state is CommentDeleted) {
                        setState(() {
                          _comments.removeWhere((c) => c.id == state.commentId);
                          widget.post.comments = _comments;
                        });
                        context
                            .read<CommunityPostsCubit>()
                            .updatePost(widget.post);
                        context.read<CommunityPostsCubit>().fetchPosts();
                      } else if (state is CommentError) {
                        setState(() => _isAddingComment = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)));
                      }
                    } catch (e) {
                      debugPrint('Error in Comment listener: $e');
                    }
                  },
                  builder: (context, state) {
                    if (_comments.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Center(
                            child: Text('Be the first to comment',
                                style: TextStyle(color: Colors.grey.shade600)),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final c = _comments[i];
                          final currentUserId = _getCurrentUserIdSafe(context);
                          final isMine = c.user?.id == currentUserId;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: c.user?.profileImage != null
                                      ? NetworkImage(c.user!.profileImage!)
                                      : null,
                                  child: c.user?.profileImage == null
                                      ? const Icon(Icons.person_outline,
                                          size: 18)
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
                                          Text(c.user?.name ?? 'Unknown',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w800)),
                                          const SizedBox(width: 8),
                                          Text(_formatTime(c.createdAt),
                                              style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12)),
                                          const Spacer(),
                                          GestureDetector(
                                            onTap: () {
                                              if (widget.post.id != null &&
                                                  c.id != null) {
                                                context
                                                    .read<CommentCubit>()
                                                    .deleteComment(
                                                        widget.post.id!, c.id!);
                                              }
                                            },
                                            child: Icon(Icons.delete_outline,
                                                size: 18,
                                                color: isMine
                                                    ? Colors.red
                                                    : Colors.grey.shade300),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.03),
                                                blurRadius: 6)
                                          ],
                                        ),
                                        child: Text(c.text ?? '',
                                            style: const TextStyle(
                                                fontSize: 14, height: 1.4)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: _comments.length,
                      ),
                    );
                  },
                ),

                // Bottom padding for input bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          ),

          // Fixed bottom input bar
          SafeArea(
            top: false,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  // small avatar preview
                  Builder(builder: (context) {
                    final userProvider =
                        Provider.of<UserProvider>(context, listen: false);
                    final dynamic userJson = userProvider.user;
                    final image = (userJson is Map<String, dynamic>)
                        ? (userJson['profileImage'] as String?)
                        : null;
                    return CircleAvatar(
                      radius: 18,
                      backgroundImage:
                          image != null ? NetworkImage(image) : null,
                      child: image == null
                          ? const Icon(Icons.person, size: 18)
                          : null,
                    );
                  }),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      enabled: !_isAddingComment,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _isAddingComment
                        ? SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)))
                        : Material(
                            color: AppColorsDark.accentBlue,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _addComment,
                              child: const SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Icon(Icons.send_rounded,
                                      color: Colors.white)),
                            ),
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
}

/// Small reaction button used in the reaction row
class _ReactionButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final String label;
  final VoidCallback? onTap;

  const _ReactionButton(
      {required this.icon,
      this.active = false,
      required this.label,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.deepPurple : Colors.grey.shade700;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: active
                  ? AppColorsDark.accentBlue.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
