import 'package:codexa_mobile/Data/services/likes_persistence_service.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/likes_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/posts_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_states/likes_state.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Domain/entities/community_entity.dart';

class PostCard extends StatefulWidget {
  final CommunityEntity post;
  final VoidCallback? onTap;

  const PostCard({Key? key, required this.post, this.onTap}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late LikesPersistenceService _likesService;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _likesService = LikesPersistenceService(
      sl<SharedPreferences>(),
      userProvider: userProvider,
    );

    // Sync local likes with backend data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncLikesWithBackend();
    });
  }

  /// Sync local persistence with backend likes data
  void _syncLikesWithBackend() {
    // Run this asynchronously without blocking
    _syncLikesAsync();
  }

  Future<void> _syncLikesAsync() async {
    if (widget.post.likes != null && widget.post.likes!.isNotEmpty) {
      // Get current user ID
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String? currentUserId;
      final user = userProvider.user;
      if (user != null) {
        if (user is Map) {
          currentUserId = (user['_id'] ?? user['id'])?.toString();
        } else {
          currentUserId = user.id?.toString();
        }
      }

      if (currentUserId != null && widget.post.id != null) {
        // Check if current user is in the likes list
        final currentUserLiked = widget.post.likes!.any(
          (like) => like.user?.toString() == currentUserId,
        );

        // Update local persistence to match backend
        if (currentUserLiked) {
          await _likesService.addLikedPost(widget.post.id!);
        } else {
          await _likesService.removeLikedPost(widget.post.id!);
        }
      }
    } else if (widget.post.id != null) {
      // If no likes on post, make sure it's not in local cache
      await _likesService.removeLikedPost(widget.post.id!);
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

  bool _isCurrentUserLiked() {
    if (widget.post.id == null) return false;
    return _likesService.isPostLiked(widget.post.id!);
  }

  void _handleLike() {
    if (widget.post.id == null) return;

    // Toggle like persistence asynchronously
    _likesService.togglePostLike(widget.post.id!);

    // Force immediate UI rebuild to show the toggled like button
    setState(() {});

    // Call API to sync with backend
    context.read<LikeCubit>().toggleLike(widget.post.id!);
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (bottomSheetContext) {
        final theme = Theme.of(bottomSheetContext);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.only(bottom: 16),
              ),

              // Delete option
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red.shade600),
                title: Text(
                  'Delete Post',
                  style: TextStyle(color: Colors.red.shade600),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showDeleteConfirmation(context);
                },
              ),
              const SizedBox(height: 8),
              // Cancel option
              ListTile(
                leading: Icon(Icons.close, color: theme.iconTheme.color),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(bottomSheetContext),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
            'Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }

  void _deletePost() {
    if (widget.post.id == null) return;
    context.read<CommunityPostsCubit>().deletePost(widget.post.id!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String? currentUserId;

    // Get user ID from UserProvider - handle both Map and typed objects
    final user = userProvider.user;
    if (user != null) {
      if (user is Map) {
        // If it's a dynamic map
        currentUserId = (user['_id'] ?? user['id'])?.toString();
      } else {
        // If it's a typed object (StudentEntity or InstructorEntity)
        currentUserId = user.id?.toString();
      }
    }

    final postAuthorId = widget.post.author?.id;
    final isOwnPost = postAuthorId == currentUserId;

    return BlocListener<LikeCubit, LikeState>(
      listener: (context, state) {
        // Refresh posts to sync with backend
        if (state is LikeSuccess) {
          context.read<CommunityPostsCubit>().fetchPosts();
        } else if (state is LikeError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: theme.brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with better styling
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 10),
                child: Row(
                  children: [
                    // Avatar with better styling
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.dividerColor,
                          width: 1,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: theme.dividerColor,
                        backgroundImage: widget.post.author?.profileImage !=
                                null
                            ? NetworkImage(widget.post.author!.profileImage!)
                            : null,
                        child: widget.post.author?.profileImage == null
                            ? Icon(Icons.person_outline,
                                size: 22, color: theme.iconTheme.color)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.author?.name ?? 'Unknown',
                            style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.textTheme.bodyLarge?.color),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateOnly(widget.post.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color),
                          ),
                        ],
                      ),
                    ),
                    // More options button - only enabled for post owner
                    if (isOwnPost)
                      IconButton(
                        onPressed: () {
                          _showPostOptions(context);
                        },
                        icon: Icon(Icons.more_vert_rounded,
                            color: theme.iconTheme.color),
                        splashRadius: 20,
                      )
                    else
                      SizedBox(width: 48), // Placeholder for alignment
                  ],
                ),
              ),

              // Content with better styling
              if (widget.post.content != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    widget.post.content!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5, color: theme.textTheme.bodyMedium?.color),
                  ),
                ),

              // Image with better styling
              if (widget.post.image != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(widget.post.image!,
                          fit: BoxFit.cover, width: double.infinity),
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Reactions row with improved styling
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    // Like button with better feedback
                    GestureDetector(
                      onTap: _handleLike,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _isCurrentUserLiked()
                              ? theme.colorScheme.primary.withOpacity(0.15)
                              : theme.dividerColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isCurrentUserLiked()
                                  ? Icons.thumb_up_alt_rounded
                                  : Icons.thumb_up_off_alt,
                              color: _isCurrentUserLiked()
                                  ? theme.colorScheme.primary
                                  : (theme.textTheme.bodyMedium?.color ??
                                      Colors.grey),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.post.likes?.length ?? 0}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.bodyMedium?.color),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Comment count with better styling
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 18,
                              color: theme.textTheme.bodyMedium?.color),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.post.comments?.length ?? 0}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyMedium?.color),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Share button with better styling
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.share_outlined,
                          color: theme.textTheme.bodyMedium?.color),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Comments preview with improved styling
              if (widget.post.comments != null &&
                  widget.post.comments!.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.post.comments!
                        .take(2)
                        .map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${c.user?.name ?? 'Unknown'}: ',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color:
                                            theme.textTheme.bodyMedium?.color),
                                  ),
                                  TextSpan(
                                    text: c.text ?? '',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.textTheme.bodySmall?.color),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
