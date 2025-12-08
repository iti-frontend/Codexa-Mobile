import 'package:flutter/material.dart';

/// Reactions bar with Like and Comment buttons
class PostReactionsBar extends StatelessWidget {
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final VoidCallback? onLikeTap;
  final bool isRTL;

  const PostReactionsBar({
    Key? key,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    this.onLikeTap,
    required this.isRTL,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ReactionButton(
            icon: Icons.thumb_up_alt_rounded,
            active: isLiked,
            label: "$likesCount",
            colorActive: theme.progressIndicatorTheme.color,
            colorInactive: theme.dividerTheme.color,
            textColor: theme.iconTheme.color,
            onTap: onLikeTap,
            isRTL: isRTL,
          ),
          ReactionButton(
            icon: Icons.comment_rounded,
            label: "$commentsCount",
            textColor: theme.iconTheme.color,
            isRTL: isRTL,
          ),
        ],
      ),
    );
  }
}

/// Reusable reaction button - theme-aware with RTL support
class ReactionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final bool active;
  final VoidCallback? onTap;
  final Color? colorActive;
  final Color? colorInactive;
  final Color? textColor;
  final bool isRTL;

  const ReactionButton({
    Key? key,
    required this.icon,
    this.label,
    this.onTap,
    this.active = false,
    this.colorActive,
    this.colorInactive,
    this.textColor,
    required this.isRTL,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = active
        ? (colorActive ?? theme.progressIndicatorTheme.color)
        : (colorInactive ?? theme.dividerTheme.color);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Row(
        children: isRTL
            ? [
                if (label != null) ...[
                  Text(
                    label!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor ?? theme.iconTheme.color,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                Icon(icon, size: 19, color: iconColor),
              ]
            : [
                Icon(icon, size: 19, color: iconColor),
                if (label != null) ...[
                  const SizedBox(width: 5),
                  Text(
                    label!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor ?? theme.iconTheme.color,
                    ),
                  )
                ]
              ],
      ),
    );
  }
}
