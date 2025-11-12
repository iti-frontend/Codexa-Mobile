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
}) {
  double screenWidth = MediaQuery.of(context).size.width;
  double responsiveFontSize = screenWidth * 0.03;

  final borderRadius = BorderRadius.circular(16);

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
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                          color: textColor,
                          fontSize: responsiveFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: textColor.withOpacity(0.9),
              ),
              dropdownColor: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
          )
        : TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: responsiveFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
  );
}
