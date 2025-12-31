import 'package:codexa_mobile/Data/services/likes_persistence_service.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/cubits/likes_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/cubits/posts_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/home_screen/community_tab/states/likes_state.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:codexa_mobile/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Domain/entities/community_entity.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;

class PostCard extends StatefulWidget {
  final CommunityEntity post;
  final VoidCallback? onTap;
  final generated.S translations; // Add translations as parameter
  final bool isRTL; // Add isRTL as parameter

  const PostCard({
    Key? key,
    required this.post,
    this.onTap,
    required this.translations, // Make it required
    required this.isRTL, // Make it required
  }) : super(key: key);

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
      return intl.DateFormat.yMMMd().format(dt);
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Directionality(
          textDirection: widget.isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle indicator
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Delete option (red and prominent)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                  ),
                  title: Text(
                    widget.translations.deletePost,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection:
                        widget.isRTL ? TextDirection.rtl : TextDirection.ltr,
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _showDeleteConfirmation(context);
                  },
                ),

                const SizedBox(height: 8),

                // Cancel option
                ListTile(
                  leading: Icon(
                    Icons.close,
                    textDirection:
                        widget.isRTL ? TextDirection.rtl : TextDirection.ltr,
                  ),
                  title: Text(
                    widget.translations.cancel,
                    textDirection:
                        widget.isRTL ? TextDirection.rtl : TextDirection.ltr,
                  ),
                  onTap: () => Navigator.pop(bottomSheetContext),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: widget.isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            widget.translations.confirm,
            textDirection: widget.isRTL ? TextDirection.rtl : TextDirection.ltr,
          ),
          content: Text(
            widget.translations.confirmDeletePost,
            textDirection: widget.isRTL ? TextDirection.rtl : TextDirection.ltr,
          ),
          actionsAlignment:
              widget.isRTL ? MainAxisAlignment.start : MainAxisAlignment.end,
          actions: widget.isRTL
              ? [
                  // RTL: Delete first, Cancel last
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, true);
                      _deletePost();
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(
                      widget.translations.delete,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(
                      widget.translations.cancel,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ]
              : [
                  // LTR: Cancel first, Delete last
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(widget.translations.cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, true);
                      _deletePost();
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(
                      widget.translations.delete,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
        ),
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
                    children: widget.isRTL
                        ? [
                            // Avatar with better styling - MOVED TO RIGHT for RTL
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
                                backgroundImage:
                                    widget.post.author?.profileImage != null
                                        ? NetworkImage(
                                            widget.post.author!.profileImage!)
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
                                    widget.post.author?.name ??
                                        widget.translations.unknown,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: theme
                                                .textTheme.bodyLarge?.color),
                                    textDirection: widget.isRTL
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDateOnly(widget.post.createdAt),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.textTheme.bodySmall?.color),
                                    textDirection: widget.isRTL
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                  ),
                                ],
                              ),
                            ),
                            // More options button - only enabled for post owner - MOVED TO LEFT for RTL
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
                          ]
                        : [
                            // Avatar with better styling - LTR layout
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
                                backgroundImage:
                                    widget.post.author?.profileImage != null
                                        ? NetworkImage(
                                            widget.post.author!.profileImage!)
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
                                    widget.post.author?.name ??
                                        widget.translations.unknown,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: theme
                                                .textTheme.bodyLarge?.color),
                                    textDirection: widget.isRTL
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDateOnly(widget.post.createdAt),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.textTheme.bodySmall?.color),
                                    textDirection: widget.isRTL
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                  ),
                                ],
                              ),
                            ),
                            // More options button - only enabled for post owner - LTR layout
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
                          height: 1.5,
                          color: theme.textTheme.bodyMedium?.color),
                      textDirection:
                          widget.isRTL ? TextDirection.rtl : TextDirection.ltr,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: widget.isRTL
                        ? [
                            // Like button with better feedback - RTL layout (reversed order)
                            GestureDetector(
                              onTap: _handleLike,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: _isCurrentUserLiked()
                                      ? (theme.brightness == Brightness.dark
                                              ? AppColorsDark.accentBlue
                                              : AppColorsLight.accentBlue)
                                          .withOpacity(0.15)
                                      : theme.dividerColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${widget.post.likes?.length ?? 0}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: theme
                                                  .textTheme.bodyMedium?.color),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      _isCurrentUserLiked()
                                          ? Icons.thumb_up_alt_rounded
                                          : Icons.thumb_up_off_alt,
                                      color: _isCurrentUserLiked()
                                          ? (theme.brightness == Brightness.dark
                                              ? AppColorsDark.accentBlue
                                              : AppColorsLight.accentBlue)
                                          : (theme.textTheme.bodyMedium
                                                  ?.color ??
                                              Colors.grey),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Comment count with better styling - RTL layout
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.dividerColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${widget.post.comments?.length ?? 0}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color:
                                            theme.textTheme.bodyMedium?.color),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(Icons.chat_bubble_outline,
                                      size: 18,
                                      color: theme.textTheme.bodyMedium?.color),
                                ],
                              ),
                            ),
                            const Spacer(),
                          ]
                        : [
                            // Like button with better feedback - LTR layout
                            GestureDetector(
                              onTap: _handleLike,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: _isCurrentUserLiked()
                                      ? (theme.brightness == Brightness.dark
                                              ? AppColorsDark.accentBlue
                                              : AppColorsLight.accentBlue)
                                          .withOpacity(0.15)
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
                                          ? (theme.brightness == Brightness.dark
                                              ? AppColorsDark.accentBlue
                                              : AppColorsLight.accentBlue)
                                          : (theme.textTheme.bodyMedium
                                                  ?.color ??
                                              Colors.grey),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${widget.post.likes?.length ?? 0}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: theme
                                                  .textTheme.bodyMedium?.color),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Comment count with better styling - LTR layout
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
                                        color:
                                            theme.textTheme.bodyMedium?.color),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
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
                                      text:
                                          '${c.user?.name ?? widget.translations.unknown}: ',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: theme
                                                  .textTheme.bodyMedium?.color),
                                    ),
                                    TextSpan(
                                      text: c.text ?? '',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: theme
                                                  .textTheme.bodySmall?.color),
                                    )
                                  ],
                                ),
                                textDirection: widget.isRTL
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
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
        ));
  }
}
