import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/likes_cubit.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_states/likes_state.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
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

  @override
  void initState() {
    super.initState();
    likesCount = widget.post.likes?.length ?? 0;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = _extractUserId(userProvider.user);
    isLiked = widget.post.likes?.any((l) => l.user == userId) ?? false;
  }

  String _formatDateOnly(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      // مثال: 20 Nov 2025  -> DateFormat.yMMMd()
      return DateFormat.yMMMd().format(dt);
      // لو تريد شكل مختلف استبدل السطر أعلاه بـ:
      // return DateFormat('yyyy-MM-dd').format(dt);
    } catch (_) {
      // لو الــ ISO غير صالح، رجّع النص كما هو أو جزء منه
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

  void _handleLike() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = _extractUserId(userProvider.user);

    // optimistic update
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

    // API call
    context.read<LikeCubit>().toggleLike(widget.post.id!);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LikeCubit, LikeState>(
      listener: (context, state) {
        if (state is LikeError) {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          final userId = _extractUserId(userProvider.user);

          // rollback optimistic change
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
                    // small action icon
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.more_vert_rounded,
                          color: Colors.grey.shade600),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),

              // content
              if (widget.post.content != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Text(widget.post.content!,
                      style: const TextStyle(fontSize: 15, height: 1.4)),
                ),

              // image (if any) — modern large card-like media
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

              // spacing
              const SizedBox(height: 12),

              // reactions row
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
                              ? Colors.deepPurple.withOpacity(0.12)
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
                                    ? Colors.deepPurple
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

                    // comments preview count button
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

                    // optional share button
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

              // comments preview (up to 2 lines) — modern inline preview
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
