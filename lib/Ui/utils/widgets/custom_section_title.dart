import 'package:flutter/material.dart';

// here this a custom widget will be used to display main progress titles
Widget customSectionTitle({
  // this for controlling the responsive
  required BuildContext context,
  required String title,
  required VoidCallback onPressed,
  required Color backgroundColor,
  required Color textColor,

  // flag for controlling the active one
  bool isSelected = false,
}) {
  // media query for sizing
  double screenWidth = MediaQuery.of(context).size.width;
  double responsiveFontSize = screenWidth * 0.03;

  return Container(
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          // if you want to edit size edit from the variable itself
          fontSize: responsiveFontSize,
        ),
      ),
    ),
  );
}
