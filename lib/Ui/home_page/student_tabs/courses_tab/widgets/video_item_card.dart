import 'package:flutter/material.dart';
import 'package:codexa_mobile/Ui/home_page/additional_screens/video_player/video_player_course.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;

/// Single video item card with lock/unlock state
class VideoItemCard extends StatelessWidget {
  final String videoTitle;
  final String videoUrl;
  final bool isLocked;
  final generated.S translations;

  const VideoItemCard({
    Key? key,
    required this.videoTitle,
    required this.videoUrl,
    required this.isLocked,
    required this.translations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Card(
        elevation: isLocked ? 0 : 2,
        color: isLocked
            ? theme.dividerTheme.color?.withOpacity(0.1)
            : theme.cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isLocked
                ? theme.dividerTheme.color?.withOpacity(0.2)
                : theme.progressIndicatorTheme.color?.withOpacity(0.1),
            child: Icon(
              isLocked ? Icons.lock_outline : Icons.play_arrow_rounded,
              color: isLocked
                  ? theme.dividerTheme.color
                  : theme.progressIndicatorTheme.color,
            ),
          ),
          title: Text(
            videoTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: theme.iconTheme.color),
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
          ),
          subtitle: isLocked
              ? Text(
            translations.enrollToUnlock,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: theme.iconTheme.color?.withOpacity(0.6),
            ),
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
          )
              : null,
          trailing: isLocked
              ? _buildLockedBadge(theme)
              : _buildWatchButton(context, theme),
        ),
      ),
    );
  }

  Widget _buildLockedBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.progressIndicatorTheme.color?.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.progressIndicatorTheme.color?.withOpacity(0.3) ??
              Colors.blue,
        ),
      ),
      child: Text(
        translations.locked,
        style: TextStyle(
          color: theme.progressIndicatorTheme.color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWatchButton(BuildContext context, ThemeData theme) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.progressIndicatorTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        if (videoUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(translations.videoUrlEmpty)),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(url: videoUrl),
          ),
        );
      },
      child: Text(
        translations.watch,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}