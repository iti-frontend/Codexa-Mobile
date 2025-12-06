import 'package:codexa_mobile/Domain/entities/community_entity.dart';
import 'package:codexa_mobile/Ui/home_page/instructor_tabs/community_tab/community_tab_cubit/posts_cubit.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

/// Shows delete confirmation dialog with double confirmation pattern
/// Returns true if user confirmed deletion, false otherwise
Future<bool> showDeletePostConfirmation(
    BuildContext context, CommunityEntity post) async {
  // Check if user owns the post
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final dynamic userJson = userProvider.user;
  String? currentUserId;
  if (userJson is Map<String, dynamic>) {
    currentUserId = (userJson['_id'] ?? userJson['id'])?.toString();
  }

  final isOwnPost = post.author?.id == currentUserId;

  if (!isOwnPost) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You can only delete your own posts')),
    );
    return false;
  }

  // First confirmation: Bottom sheet
  final shouldProceed = await showModalBottomSheet<bool>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Icon(Icons.delete_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text(
            'Delete Post',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'This action cannot be undone',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    ),
  );

  if (shouldProceed != true) return false;

  // Second confirmation: Dialog
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Are you sure?'),
      content: const Text(
        'Do you really want to delete this post? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );

  return confirmed == true;
}

/// Performs post deletion via CommunityPostsCubit
Future<void> deletePost(BuildContext context, CommunityEntity post) async {
  if (post.id == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cannot delete post: Invalid ID')),
    );
    return;
  }

  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    await context.read<CommunityPostsCubit>().deletePost(post.id!);

    // Close loading dialog
    if (context.mounted) Navigator.pop(context);

    // Success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    // Close loading dialog
    if (context.mounted) Navigator.pop(context);

    // Error message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: $e')),
      );
    }
  }
}
