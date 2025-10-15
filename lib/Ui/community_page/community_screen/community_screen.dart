import 'package:flutter/material.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_appbar.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_bottom_navbar.dart';
import 'package:codexa_mobile/Ui/home_page/tabs/community_tab/community.dart';

class CommunityScreen extends StatefulWidget {
  static const String routeName = "/community";
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColorsDark.seconderyBackground,
        title: const CustomAppbar(profileImage: "assets/images/review-1.jpg"),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      body: const CommunityTab(),
    );
  }
}
