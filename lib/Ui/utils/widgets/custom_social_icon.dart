import 'package:flutter/material.dart';

class CustomSocialIcon extends StatelessWidget {
  final String assetPath;
  final VoidCallback? onTap;
  final double height;
  final double width;

  const CustomSocialIcon({
    super.key,
    required this.assetPath,
    this.onTap,
    this.height = 50,
    this.width = 90,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            height: 24,
          ),
        ),
      ),
    );
  }
}
