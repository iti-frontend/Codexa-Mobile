import 'package:codexa_mobile/Data/services/likes_persistence_service.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/likes_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/posts_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_states/likes_state.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/theme_provider.dart';
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
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dynamic userJson = userProvider.user;
    String? currentUserId;

    if (userJson != null && userJson is Map) {
      currentUserId = (userJson['_id'] ?? userJson['id'])?.toString();
    }

    final postAuthorId = widget.post.author?.id;
    final isOwnPost = postAuthorId == currentUserId;

    return BlocListener<LikeCubit, LikeState>(
      listener: (context, state) {
        if (state is LikeError) {
          final userProvider =
          Provider.of<UserProvider>(context, listen: false);
          final userId = _extractUserId(userProvider.user);

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
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
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
                          ? Icon(Icons.person_outline,
                          size: 22, color: theme.iconTheme.color)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.author?.name ?? 'Unknown',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700,color: theme.iconTheme.color),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateOnly(widget.post.createdAt),
                            style: theme.textTheme.bodySmall ?.copyWith(color: theme.iconTheme.color),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        // Bottom sheet logic (unchanged)
                      },
                      icon: Icon(Icons.more_vert_rounded,
                          color: theme.iconTheme.color),
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
                  child: Text(
                    widget.post.content!,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4, color: theme.iconTheme.color),
                  ),
                ),

              // Image
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
                    GestureDetector(
                      onTap: _handleLike,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isLiked
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : theme.dividerColor.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isLiked
                                  ? Icons.thumb_up_alt_rounded
                                  : Icons.thumb_up_off_alt,
                              color: isLiked
                                  ? theme.colorScheme.primary
                                  : theme.iconTheme.color,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$likesCount',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600, color:theme.iconTheme.color),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Comment count
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 18, color: theme.iconTheme.color),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.post.comments?.length ?? 0}',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600, color: theme.iconTheme.color),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Share button
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.share_outlined, color: theme.iconTheme.color),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Comments preview
              if (widget.post.comments != null &&
                  widget.post.comments!.isNotEmpty)
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.post.comments!
                        .take(2)
                        .map(
                          (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${c.user?.name ?? 'Unknown'}: ',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700,color: theme.iconTheme.color),
                              ),
                              TextSpan(
                                text: c.text ?? '',
                                style: theme.textTheme.bodyMedium ?.copyWith(color: theme.iconTheme.color),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
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
