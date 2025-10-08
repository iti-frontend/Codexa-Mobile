import 'package:codexa_mobile/Ui/utils/provider_ui/theme_provider.dart';
import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class CustomAppbar extends StatelessWidget {
  final String profileImage;

  const CustomAppbar({required this.profileImage, super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ThemeProvider>(context);
    return AppBar(
      backgroundColor: AppColorsDark.seconderyBackground,
      title: Row(
        // ! Appbar background
        children: [
          // ! Profile Picture
          Align(
            alignment: Alignment.centerLeft,
            child: CircleAvatar(
              backgroundImage: AssetImage(profileImage),
              radius: 20,
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          // ! Search text field
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: AppColorsDark.cardBackground,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                style: TextStyle(
                  color: AppColorsLight.primaryBackground,
                ),
                cursorColor: AppColorsLight.primaryBackground,
                decoration: InputDecoration(
                  hintText: "Search ",
                  hintStyle: TextStyle(
                      color: AppColorsLight.primaryBackground, fontSize: 16),
                  prefixIcon: Icon(Icons.search,
                      color: AppColorsLight.primaryBackground),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          // ! Icon chat
          Stack(
            children: [
              Icon(CupertinoIcons.chat_bubble,
                  color: AppColorsLight.primaryBackground, size: 28),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColorsDark.accentBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          // ! Icon notifications
          Stack(
            children: [
              Icon(CupertinoIcons.bell,
                  color: AppColorsLight.primaryBackground, size: 28),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColorsDark.accentBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
