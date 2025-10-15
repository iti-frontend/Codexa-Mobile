import 'package:flutter/material.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_post_card.dart';

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsDark.seconderyBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: isWide
                      ? _buildGridLayout() // 2-column for large screens
                      : _buildListLayout(), // 1-column for phones
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Single column list (mobile)
  Widget _buildListLayout() {
    return Column(
      children: const [
        CustomPostCard(
          name: "Alexei Volkov",
          title: "Lead AI Researcher @ FutureCorp",
          content:
              "Just published a new article on the ethical implications of advanced AI. Would love to hear your thoughts! #AI #Ethics #FutureTech",
          image:
              "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80",
          likes: "1.2k",
          comments: "98",
        ),
        SizedBox(height: 16),
        CustomPostCard(
          name: "Sarah Chen",
          title: "Data Scientist @ Innovate Inc.",
          content:
              "Excited to share my latest project on predictive modeling for market trends. Check out the GitHub repo in my profile! #DataScience #MachineLearning #BigData",
          image:
              "https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=800&q=80",
          likes: "845",
          comments: "52",
        ),
        SizedBox(height: 16),
        CustomPostCard(
          name: "David Lee",
          title: "ML Engineer @ Techverse",
          content:
              "Working on federated learning solutions for privacy-preserving AI. Collaboration welcome! #ML #Privacy #Innovation",
          image:
              "https://images.unsplash.com/photo-1556157382-97eda2d62296?auto=format&fit=crop&w=800&q=80",
          likes: "640",
          comments: "31",
        ),
      ],
    );
  }

  // Grid-like layout (tablets/web) — adaptive with natural height
  Widget _buildGridLayout() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: const [
        SizedBox(
          width: 480, // Each card width — will auto-wrap to next line
          child: CustomPostCard(
            name: "Alexei Volkov",
            title: "Lead AI Researcher @ FutureCorp",
            content:
                "Just published a new article on the ethical implications of advanced AI. Would love to hear your thoughts! #AI #Ethics #FutureTech",
            image:
                "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80",
            likes: "1.2k",
            comments: "98",
          ),
        ),
        SizedBox(
          width: 480,
          child: CustomPostCard(
            name: "Sarah Chen",
            title: "Data Scientist @ Innovate Inc.",
            content:
                "Excited to share my latest project on predictive modeling for market trends. Check out the GitHub repo in my profile! #DataScience #MachineLearning #BigData",
            image:
                "https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=800&q=80",
            likes: "845",
            comments: "52",
          ),
        ),
        SizedBox(
          width: 480,
          child: CustomPostCard(
            name: "David Lee",
            title: "ML Engineer @ Techverse",
            content:
                "Working on federated learning solutions for privacy-preserving AI. Collaboration welcome! #ML #Privacy #Innovation",
            image:
                "https://images.unsplash.com/photo-1556157382-97eda2d62296?auto=format&fit=crop&w=800&q=80",
            likes: "640",
            comments: "31",
          ),
        ),
        SizedBox(
          width: 480,
          child: CustomPostCard(
            name: "Emma Brown",
            title: "UX Specialist @ CreativHub",
            content:
                "Just wrapped up a study on user experience for healthcare apps. Insights are eye-opening! #UXDesign #HealthTech",
            image:
                "https://images.unsplash.com/photo-1581093588401-22b3f5f3df52?auto=format&fit=crop&w=800&q=80",
            likes: "932",
            comments: "74",
          ),
        ),
      ],
    );
  }
}
