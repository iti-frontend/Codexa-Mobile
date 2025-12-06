import 'package:flutter/material.dart';

/// Custom widget used to display main progress titles.
/// Supports optional dropdown functionality while keeping backward compatibility.
Widget customSectionTitle({
  required BuildContext context,
  required String title,
  required VoidCallback onPressed,
  required Color backgroundColor,
  required Color textColor,
  bool isSelected = false,

  // 👇 جديد: لو حابب تخليه Dropdown
  List<String>? dropdownItems,
  String? selectedValue,
  ValueChanged<String?>? onChanged,
  bool isRTL = false,
}) {
  double screenWidth = MediaQuery.of(context).size.width;
  double responsiveFontSize = screenWidth * 0.03;

  final borderRadius = BorderRadius.circular(16);


  TextAlign textAlign = isRTL ? TextAlign.right : TextAlign.left;
  Alignment dropdownAlignment = isRTL ? Alignment.centerRight : Alignment.centerLeft;

  return Container(
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius,
      boxShadow: isSelected
          ? [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 3),
          blurRadius: 8,
        ),
      ]
          : [],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: dropdownItems != null && dropdownItems.isNotEmpty
        ? DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedValue ?? dropdownItems.first,
        items: dropdownItems
            .map(
              (item) => DropdownMenuItem<String>(
            value: item,
            child: Container(
              alignment: dropdownAlignment,
              child: Text(
                item,
                style: TextStyle(
                  color: textColor,
                  fontSize: responsiveFontSize,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: textAlign,
              ),
            ),
          ),
        )
            .toList(),
        onChanged: onChanged,
        icon: Icon(
          isRTL ? Icons.keyboard_arrow_left : Icons.keyboard_arrow_down_rounded,
          color: textColor.withOpacity(0.9),
        ),
        dropdownColor: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        alignment: dropdownAlignment,
        iconSize: 24,
        underline: Container(height: 0),
        isExpanded: true,
        menuMaxHeight: 300,
        selectedItemBuilder: (context) {
          return dropdownItems.map((item) {
            return Container(
              alignment: dropdownAlignment,
              child: Text(
                item,
                style: TextStyle(
                  color: textColor,
                  fontSize: responsiveFontSize,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: textAlign,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList();
        },
      ),
    )
        : TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding:
        const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      child: Container(
        alignment: dropdownAlignment,
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: responsiveFontSize,
            fontWeight: FontWeight.w600,
          ),
          textAlign: textAlign,
        ),
      ),
    ),
  );
}