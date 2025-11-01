import 'package:flutter/material.dart';

class CustomPostCard extends StatelessWidget {
  final String name;
  final String title;
  final String content;
  final String image;
  final String likes;
  final String comments;

  const CustomPostCard({
    super.key,
    required this.name,
    required this.title,
    required this.content,
    required this.image,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage("")), // replace with real image
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.iconTheme.color,
                        ),
                      ),
                      Text(
                        title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.iconTheme.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Post content
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: theme.iconTheme.color,
              ),
            ),

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 12),

            // Likes / Comments / Share
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 16,
                  children: [
                    _buildStat(context, Icons.thumb_up_alt_outlined, likes),
                    _buildStat(context, Icons.comment_outlined, comments),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.ios_share, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.iconTheme.color,
          ),
        ),
      ],
    );
  }
}
