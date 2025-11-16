import 'package:flutter/material.dart';
import 'package:codexa_mobile/Domain/entities/community/community_entity.dart';

class PostCard extends StatelessWidget {
  final CommunityEntity post;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final String currentToken;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLike,
    required this.currentToken,
  });

  @override
  Widget build(BuildContext context) {
    final hasLiked = currentToken.isNotEmpty &&
        (post.likes?.contains(currentToken) ?? false);
    final authorImage = post.author?.profileImage ?? "";
    final authorName = post.author?.name ?? "Anonymous";

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Author
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: authorImage.isNotEmpty
                        ? NetworkImage(authorImage)
                        : const AssetImage("assets/images/default_avatar.png")
                            as ImageProvider,
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(authorName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(post.authorType ?? "",
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 12),

              /// Content
              Text(post.content ?? "",
                  style: const TextStyle(fontSize: 15, height: 1.4)),

              if ((post.image ?? "").isNotEmpty) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    post.image!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 220,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                )
              ],

              const SizedBox(height: 12),

              /// Like Row
              Row(
                children: [
                  IconButton(
                    onPressed: onLike,
                    icon: Icon(
                      hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      color: hasLiked ? Colors.blue : Colors.grey,
                      size: 26,
                    ),
                  ),
                  Text(
                    "${post.likes?.length ?? 0} Likes",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    "${post.comments?.length ?? 0} Comments",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
