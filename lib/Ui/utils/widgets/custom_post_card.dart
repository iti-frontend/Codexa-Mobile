import 'package:flutter/material.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: AppColorsDark.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(""), //TODO add user image
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColorsDark.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColorsDark.accentGreen,
                        fontSize: 13,
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
            style: const TextStyle(
              color: AppColorsDark.secondaryText,
              fontSize: 14,
              height: 1.4,
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
                  _buildStat(Icons.thumb_up_alt_outlined, likes),
                  _buildStat(Icons.comment_outlined, comments)
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.ios_share,
                  size: 20,
                  color: AppColorsDark.secondaryText,
                ),
                tooltip: "Share post",
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColorsDark.secondaryText,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: AppColorsDark.secondaryText,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
