import 'package:flutter/material.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_post_card.dart';

class CommunityInstructorTab extends StatelessWidget {
  const CommunityInstructorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: isWide ? _buildGridLayout() : _buildListLayout(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

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
      ],
    );
  }

  Widget _buildGridLayout() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: const [
        SizedBox(
          width: 480,
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
      ],
    );
  }
}
