import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool haveBanner; //this flag added to control cards have banner or not

  const DashboardCard({
    super.key,
    this.title,
    required this.child,
    //this flag set to true cause this will be the most scenario we will be faced
    this.haveBanner = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsDark.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if card doesn't have banner you need when calling to call the flag and set it to false
          haveBanner
              // nullable expression
              ? Text(title ?? '',
                  style: const TextStyle(
                      color: AppColorsDark.secondaryText,
                      fontWeight: FontWeight.bold,
                      fontSize: 16))
              : SizedBox(),
          // empty size box to remove space entirely
          haveBanner ? const SizedBox(height: 12) : SizedBox(),
          child,
        ],
      ),
    );
  }
}

class CourseProgressItem extends StatelessWidget {
  final String title;
  final double progress;
  final Color color;

  // those added to control category card
  final bool hasCategory;
  final String? categoryTitle;
  final String? categoryPercentage;

  const CourseProgressItem({
    super.key,
    required this.title,
    required this.progress,
    required this.color,
    this.categoryTitle,
    this.categoryPercentage,
    this.hasCategory = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive font sizes based on screen width
    double titleFontSize = screenWidth < 400
        ? 12
        : screenWidth < 600
            ? 14
            : 16;

    double categoryFontSize = screenWidth < 400 ? 10 : 12;

    return Row(
      children: [
        // image card until replaced with original one
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColorsDark.secondaryText,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // category header
              if (hasCategory) ...[
                Text(
                  categoryTitle ?? '',
                  style: TextStyle(
                    fontSize: categoryFontSize,
                    color: AppColorsDark.accentGreen,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10.0),
              ],

              // course title + percentage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Wrap title in Flexible + TextOverflow.ellipsis
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: AppColorsDark.secondaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: titleFontSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),

                  // optional category percentage
                  if (hasCategory)
                    Text(
                      categoryPercentage ?? '',
                      style: TextStyle(
                        color: AppColorsDark.accentGreen,
                        fontSize: categoryFontSize,
                      ),
                    ),
                ],
              ),
              SizedBox(height: hasCategory ? 15.0 : 6),
              LinearProgressIndicator(
                value: progress,
                color: color,
                backgroundColor: AppColorsDark.secondaryText,
                borderRadius: BorderRadius.circular(10),
                minHeight: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CommunityItem extends StatelessWidget {
  final String name;
  final String action;
  final String message;
  final String time;

  const CommunityItem({
    super.key,
    required this.name,
    required this.action,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
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
                            color: AppColorsDark.secondaryText,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: action,
                        style: const TextStyle(
                            color: AppColorsDark.secondaryText)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(message,
                  style: TextStyle(
                      color: AppColorsDark.secondaryText, fontSize: 13)),
              const SizedBox(height: 4),
              Text(time,
                  style: TextStyle(
                      color: AppColorsDark.secondaryText, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class SkillCard extends StatelessWidget {
  final String title;
  final String level;
  final double progress;

  const SkillCard({
    super.key,
    required this.title,
    required this.level,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColorsDark.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColorsDark.secondaryText,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(level,
              style:
                  TextStyle(color: AppColorsDark.secondaryText, fontSize: 12)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            color: AppColorsDark.accentGreen,
            backgroundColor: AppColorsDark.secondaryText,
            minHeight: 5,
          ),
        ],
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  final String title;
  final String subtitle;

  const StatBox({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColorsDark.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    color: AppColorsDark.secondaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    color: AppColorsDark.secondaryText, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
