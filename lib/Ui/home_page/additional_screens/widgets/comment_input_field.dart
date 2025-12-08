import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/generated/l10n.dart' as generated;

/// Comment input field with user avatar and send button
class CommentInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;
  final bool isRTL;
  final generated.S translations;

  const CommentInputField({
    Key? key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
    required this.isRTL,
    required this.translations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 6,
              offset: const Offset(0, -1),
            )
          ],
        ),
        child: Row(
          children: isRTL
              ? _buildRTLLayout(context, theme)
              : _buildLTRLayout(context, theme),
        ),
      ),
    );
  }

  List<Widget> _buildRTLLayout(BuildContext context, ThemeData theme) {
    return [
      // RTL layout: Send button first
      _buildSendButton(theme),
      const SizedBox(width: 10),
      Expanded(child: _buildTextField(theme)),
      const SizedBox(width: 10),
      _buildUserAvatar(context, theme),
    ];
  }

  List<Widget> _buildLTRLayout(BuildContext context, ThemeData theme) {
    return [
      // LTR layout: Avatar first
      _buildUserAvatar(context, theme),
      const SizedBox(width: 10),
      Expanded(child: _buildTextField(theme)),
      const SizedBox(width: 10),
      _buildSendButton(theme),
    ];
  }

  Widget _buildTextField(ThemeData theme) {
    return TextField(
      controller: controller,
      maxLines: null,
      style: TextStyle(
        color: theme.iconTheme.color,
        fontSize: 14,
      ),
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      textAlign: isRTL ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        hintText: translations.writeAComment,
        hintStyle: TextStyle(
          color: theme.dividerTheme.color?.withOpacity(0.6),
          fontSize: 14,
        ),
        filled: true,
        fillColor: theme.dividerColor.withOpacity(0.05),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: theme.dividerColor.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: theme.progressIndicatorTheme.color ?? Colors.blue,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton(ThemeData theme) {
    return GestureDetector(
      onTap: isLoading ? null : onSend,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.progressIndicatorTheme.color,
          shape: BoxShape.circle,
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.send_rounded,
                size: 18,
                color: Colors.white,
              ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context, ThemeData theme) {
    String? profileImageUrl;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      // Extract profileImage from different user types
      if (user is StudentEntity) {
        profileImageUrl = user.profileImage;
      } else if (user is InstructorEntity) {
        profileImageUrl = user.profileImage;
      } else if (user is Map<String, dynamic>) {
        profileImageUrl = user['profileImage'] as String?;
      } else if (user != null) {
        // Try dynamic access as fallback
        try {
          profileImageUrl = (user as dynamic).profileImage?.toString();
        } catch (_) {
          profileImageUrl = null;
        }
      }
    } catch (_) {
      profileImageUrl = null;
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: theme.dividerColor.withOpacity(0.1),
      backgroundImage: (profileImageUrl != null && profileImageUrl.isNotEmpty)
          ? NetworkImage(profileImageUrl)
          : null,
      child: (profileImageUrl == null || profileImageUrl.isEmpty)
          ? Icon(
              Icons.person_outline,
              color: theme.dividerTheme.color,
            )
          : null,
    );
  }
}
