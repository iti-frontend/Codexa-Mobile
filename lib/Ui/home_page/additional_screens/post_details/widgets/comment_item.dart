import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;

/// Single comment item widget with RTL support
class CommentItem extends StatelessWidget {
  final CommentsEntity comment;
  final bool isMine;
  final VoidCallback? onDelete;
  final bool isRTL;
  final generated.S translations;

  const CommentItem({
    Key? key,
    required this.comment,
    required this.isMine,
    this.onDelete,
    required this.isRTL,
    required this.translations,
  }) : super(key: key);

  String _formatTime(String? dateStr, BuildContext context) {
    if (dateStr == null) return '';
    try {
      final locale = Localizations.localeOf(context).languageCode;
      if (locale == 'ar') {
        timeago.setLocaleMessages('ar', timeago.ArMessages());
        return timeago.format(DateTime.parse(dateStr), locale: 'ar');
      }
      return timeago.format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.1),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // Avatar on left for both RTL/LTR (for consistency)
            _buildAvatar(theme),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.user?.name ?? translations.unknown,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.iconTheme.color,
                          fontSize: 13,
                        ),
                        textAlign: isRTL ? TextAlign.right : TextAlign.left,
                        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                      ),
                      const SizedBox(width: 10),
                        Text(
                          _formatTime(comment.createdAt, context),
                          style: TextStyle(
                            color: theme.dividerTheme.color?.withOpacity(0.7),
                            fontSize: 11,
                          ),
                          textAlign: isRTL ? TextAlign.right : TextAlign.left,
                          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                        ),
                      if (isMine) const Spacer(),
                      if (isMine) _buildDeleteButton(),

                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    comment.text ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: theme.iconTheme.color,
                    ),
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                    textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: theme.dividerColor.withOpacity(0.1),
      backgroundImage: comment.user?.profileImage != null
          ? NetworkImage(comment.user!.profileImage!)
          : null,
      child: comment.user?.profileImage == null
          ? Icon(
        Icons.person_outline,
        size: 16,
        color: theme.dividerTheme.color,
      )
          : null,
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: onDelete,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.delete_outline,
          size: 16,
          color: Colors.red,
        ),
      ),
    );
  }
}