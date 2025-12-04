import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../localization/localization_service.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}

class DirectionalWidget extends StatelessWidget {
  final Widget child;

  const DirectionalWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: LocalizationService.textDirection,
      child: child,
    );
  }
}

class LocalizedText extends StatelessWidget {
  final String? text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const LocalizedText({
    super.key,
    this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? '',
      style: style,
      textAlign: textAlign ??
          (LocalizationService.isRTL() ? TextAlign.right : TextAlign.left),
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

class LocalizedTextField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int? maxLines;
  final void Function(String)? onChanged;

  const LocalizedTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      textDirection:
          LocalizationService.isRTL() ? TextDirection.rtl : TextDirection.ltr,
      textAlign: LocalizationService.isRTL() ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        suffixIcon: suffixIcon,
        hintTextDirection:
            LocalizationService.isRTL() ? TextDirection.rtl : TextDirection.ltr,
        alignLabelWithHint: true,
      ),
    );
  }
}
