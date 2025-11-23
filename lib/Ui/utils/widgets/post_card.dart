import 'package:codexa_mobile/Data/services/likes_persistence_service.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/likes_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/posts_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_states/likes_state.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:codexa_mobile/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../Domain/entities/community_entity.dart';

class PostCard extends StatefulWidget {
  final CommunityEntity post;
  final VoidCallback? onTap;

  const PostCard({Key? key, required this.post, this.onTap}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool isLiked;
  late int likesCount;
  late LikesPersistenceService _likesService;

  @override
  void initState() {
    super.initState();
    _likesService = sl<LikesPersistenceService>();
    likesCount = widget.post.likes?.length ?? 0;

    // Initialize like state from persistence service
    if (widget.post.id != null) {
      isLiked = _likesService.isPostLiked(widget.post.id!);
    } else {
      isLiked = false;
    }
  }

  String _formatDateOnly(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat.yMMMd().format(dt);
    } catch (_) {
      return iso.split('T').first;
    }
  }

  String? _extractUserId(dynamic userJson) {
    try {
      if (userJson is Map<String, dynamic>) {
        return (userJson['_id'] ?? userJson['id'])?.toString();
      }
    } catch (_) {}
    return null;
  }

  void _handleLike() async {
    if (widget.post.id == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = _extractUserId(userProvider.user);

    // Optimistic update
    setState(() {
      if (isLiked) {
        likesCount = (likesCount - 1).clamp(0, 999999);
        widget.post.likes?.removeWhere((l) => l.user == userId);
      } else {
        likesCount = likesCount + 1;
        widget.post.likes ??= [];
        widget.post.likes!
            .add(LikesEntity(user: userId, userType: userProvider.role));
      }
      isLiked = !isLiked;
    });

    // Persist locally
    await _likesService.togglePostLike(widget.post.id!);

    // API call
    context.read<LikeCubit>().toggleLike(widget.post.id!);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dynamic userJson = userProvider.user;
    String? currentUserId;

    // Relaxed type check and debug logging
    if (userJson != null) {
      if (userJson is Map) {
        currentUserId = (userJson['_id'] ?? userJson['id'])?.toString();
      } else {
        print('DEBUG: userJson is not a Map: ${userJson.runtimeType}');
      }
    }

    final postAuthorId = widget.post.author?.id;
    final isOwnPost = postAuthorId == currentUserId;

    // Debug print to verify IDs
    if (widget.post.content == 'debug post') {
      print('CHECKING OWN POST:');
      print('Current User ID: $currentUserId');
      print('Post Author ID: $postAuthorId');
      print('Is Own Post: $isOwnPost');
    }

    return BlocListener<LikeCubit, LikeState>(
      listener: (context, state) {
        if (state is LikeError) {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          final userId = _extractUserId(userProvider.user);

          // Rollback optimistic change on error
          setState(() {
            if (isLiked) {
              likesCount = (likesCount - 1).clamp(0, 999999);
              widget.post.likes?.removeWhere((l) => l.user == userId);
            } else {
              likesCount = likesCount + 1;
              widget.post.likes ??= [];
              widget.post.likes!
                  .add(LikesEntity(user: userId, userType: userProvider.role));
            }
            isLiked = !isLiked;
          });

          // Rollback persistence
          if (widget.post.id != null) {
            _likesService.togglePostLike(widget.post.id!);
          }

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 6))
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: avatar, name, time, actions
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: widget.post.author?.profileImage != null
                          ? NetworkImage(widget.post.author!.profileImage!)
                          : null,
                      child: widget.post.author?.profileImage == null
                          ? const Icon(Icons.person_outline,
                              size: 22, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.post.author?.name ?? 'Unknown',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateOnly(widget.post.createdAt),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    // More menu icon with delete functionality
                    IconButton(
                      onPressed: () async {
                        final userProvider =
                            Provider.of<UserProvider>(context, listen: false);
                        final dynamic userJson = userProvider.user;
                        String? currentUserId;
                        if (userJson is Map) {
                          currentUserId =
                              (userJson['_id'] ?? userJson['id'])?.toString();
                        }

                        final isOwnPost =
                            widget.post.author?.id == currentUserId;

                        print('DEBUG: Clicked Menu');
                        print('Current User ID: $currentUserId');
                        print('Post Author ID: ${widget.post.author?.id}');
                        print('Is Own Post: $isOwnPost');

                        // TEMPORARILY DISABLED CHECK FOR DEBUGGING
                        // if (!isOwnPost) {
                        //   return; // Don't show menu for other users' posts
                        // }

                        // Show bottom sheet
                        final confirmed = await showModalBottomSheet<bool>(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (sheetContext) => Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ListTile(
                                  leading: Icon(Icons.delete_outline,
                                      color: Colors.red.shade400),
                                  title: const Text('Delete Post',
                                      style: TextStyle(color: Colors.red)),
                                  onTap: () =>
                                      Navigator.pop(sheetContext, true),
                                ),
                                const SizedBox(height: 8),
                                ListTile(
                                  leading: const Icon(Icons.close),
                                  title: const Text('Cancel'),
                                  onTap: () =>
                                      Navigator.pop(sheetContext, false),
                                ),
                              ],
                            ),
                          ),
                        );

                        if (confirmed != true) return;

                        // Second confirmation dialog
                        if (!context.mounted) return;
                        final doubleConfirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: const Text('Are you sure?'),
                            content: const Text(
                              'Do you really want to delete this post? This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.red),
                                child: const Text('Delete',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );

                        if (doubleConfirmed != true) return;

                        // Delete post
                        if (!context.mounted) return;
                        if (widget.post.id != null) {
                          context
                              .read<CommunityPostsCubit>()
                              .deletePost(widget.post.id!);
                        }
                      },
                      // ALWAYS SHOW ICON FOR DEBUGGING
                      icon: Icon(Icons.more_vert_rounded,
                          color: Colors.grey.shade600),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),

              // Content
              if (widget.post.content != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Text(widget.post.content!,
                      style: const TextStyle(fontSize: 15, height: 1.4)),
                ),

              // Image (if any)
              if (widget.post.image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(widget.post.image!,
                          fit: BoxFit.cover, width: double.infinity),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // Reactions row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    // Like button with pill
                    GestureDetector(
                      onTap: _handleLike,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isLiked
                              ? AppColorsDark.accentBlue.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Icon(
                                isLiked
                                    ? Icons.thumb_up_alt_rounded
                                    : Icons.thumb_up_off_alt,
                                color: isLiked
                                    ? AppColorsDark.accentBlue
                                    : Colors.grey.shade700,
                                size: 18),
                            const SizedBox(width: 8),
                            Text('$likesCount',
                                style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),

                    // Comments preview count button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(18)),
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 18, color: Colors.grey.shade700),
                          const SizedBox(width: 8),
                          Text('${widget.post.comments?.length ?? 0}',
                              style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Share button
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.share_outlined,
                          color: Colors.grey.shade700),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Comments preview (up to 2 lines)
              if (widget.post.comments != null &&
                  widget.post.comments!.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.post.comments!
                        .take(2)
                        .map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: '${c.user?.name ?? 'Unknown'}: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey.shade900)),
                                    TextSpan(
                                        text: c.text ?? '',
                                        style: TextStyle(
                                            color: Colors.grey.shade800)),
                                  ],
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
