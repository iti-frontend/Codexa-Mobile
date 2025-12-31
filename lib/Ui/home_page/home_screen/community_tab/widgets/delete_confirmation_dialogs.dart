import 'package:flutter/material.dart';

/// Reusable confirmation dialogs for delete operations in Community module

/// Shows a double confirmation flow for deleting a post
/// Returns true if user confirmed deletion, false otherwise
Future<bool> showDeletePostConfirmation(BuildContext context) async {
  // First confirmation: Bottom Sheet with options
  final shouldProceed = await showModalBottomSheet<bool>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Delete option (red and prominent)
          ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red.shade400),
            title: const Text(
              'Delete Post',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => Navigator.pop(sheetContext, true),
          ),

          const SizedBox(height: 8),

          // Cancel option
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Cancel'),
            onTap: () => Navigator.pop(sheetContext, false),
          ),
        ],
      ),
    ),
  );

  // User canceled at bottom sheet
  if (shouldProceed != true) return false;

  // Second confirmation: Alert Dialog
  if (!context.mounted) return false;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Are you sure?'),
      content: const Text(
        'Do you really want to delete this post? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text(
            'Delete',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  return confirmed == true;
}

/// Shows a single confirmation dialog for deleting a comment
/// Returns true if user confirmed deletion, false otherwise
Future<bool> showDeleteCommentConfirmation(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Delete Comment?'),
      content: const Text('This comment will be permanently deleted.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text(
            'Delete',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  return confirmed == true;
}
