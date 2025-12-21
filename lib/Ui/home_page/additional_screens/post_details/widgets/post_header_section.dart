import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;

/// Post header section showing author info, content, and image
class PostHeaderSection extends StatelessWidget {
  final CommunityEntity post;
  final bool isRTL;
  final generated.S translations;

  const PostHeaderSection({
    Key? key,
    required this.post,
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
    final maxImageHeight = MediaQuery.of(context).size.height * .35;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Author Row
          Row(
            children: [
              _buildAuthorAvatar(theme),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author?.name ?? translations.unknown,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.iconTheme.color,
                        fontSize: 15,
                      ),
                      textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(post.createdAt, context),
                      style: TextStyle(
                        color: theme.dividerTheme.color?.withOpacity(0.7),
                        fontSize: 11,
                      ),
                      textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Post text
          if (post.content != null)
            Text(
              post.content!,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: theme.iconTheme.color,
              ),
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            ),

          const SizedBox(height: 12),

          /// IMAGE (auto scaled)
          if (post.image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxImageHeight),
                child: Image.network(
                  post.image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthorAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: theme.dividerColor.withOpacity(0.1),
      backgroundImage: post.author?.profileImage != null
          ? NetworkImage(post.author!.profileImage!)
          : null,
      child: post.author?.profileImage == null
          ? Icon(Icons.person_outline, color: theme.dividerTheme.color)
          : null,
    );
  }
}