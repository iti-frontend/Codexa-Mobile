import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';

class RecentActivityItem extends StatelessWidget {
  final String name;
  final String action;
  final String subject;
  final String timeAgo;
  final String avatarImg;

  const RecentActivityItem({
    super.key,
    required this.name,
    required this.action,
    required this.subject,
    required this.timeAgo,
    required this.avatarImg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: AssetImage(avatarImg),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$name ",
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColorsDark.accentBlueAuth),
                    ),
                    TextSpan(
                        text: action,
                        style: TextStyle(color: AppColorsDark.primaryText)),
                    TextSpan(
                      text: " $subject",
                      style: const TextStyle(color: Colors.blue),
                    ),
                    const TextSpan(text: "."),
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
