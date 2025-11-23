import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';

class RecentActivityItem extends StatelessWidget {
  final String action;
  final String? avatarImg;
  final String name;
  final String subject;
  final String timeAgo;

  const RecentActivityItem({
    super.key,
    required this.action,
    this.avatarImg,
    required this.name,
    required this.subject,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (avatarImg != null && avatarImg!.startsWith('http')) {
      imageProvider = NetworkImage(avatarImg!);
    } else if (avatarImg != null && avatarImg!.isNotEmpty) {
      imageProvider = AssetImage(avatarImg!);
    } else {
      imageProvider = const AssetImage("assets/images/review-1.jpg");
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: imageProvider,
          onBackgroundImageError: (_, __) {
            // Fallback is handled by the provider logic above mostly,
            // but for network errors we might want a listener.
            // For simplicity, we trust the provider or let it fail gracefully.
          },
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: AppColorsDark.seconderyBackground,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: "$name ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: "$action ",
                    ),
                    TextSpan(
                      text: subject,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timeAgo,
                style: TextStyle(
                  color: AppColorsDark.secondaryText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
