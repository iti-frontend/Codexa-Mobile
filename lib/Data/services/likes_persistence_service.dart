import 'package:shared_preferences/shared_preferences.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/auth_provider.dart';

/// Service for persisting liked post IDs locally and syncing with backend
/// This ensures likes persist across app restarts and are user-specific
class LikesPersistenceService {
  final SharedPreferences prefs;
  final UserProvider? userProvider; // Add optional user provider

  LikesPersistenceService(this.prefs, {this.userProvider});

  /// Get current user ID for prefixing keys
  String _getCurrentUserKey() {
    if (userProvider == null || userProvider!.user == null) {
      return 'guest_';
    }

    String? userId;

    // Try to get user ID from different possible sources
    final user = userProvider!.user;

    if (user is Map) {
      // If it's a dynamic map
      userId = user['_id'] ?? user['id'];
    } else {
      // If it's a typed object (StudentEntity or InstructorEntity)
      // Both have 'id' property
      userId = user.id;
    }

    return userId != null ? '${userId}_' : 'guest_';
  }

  /// Get all liked post IDs from local storage for current user
  List<String> getLikedPostIds() {
    final key = _getCurrentUserKey() + 'liked_posts';
    return prefs.getStringList(key) ?? [];
  }

  /// Check if a specific post is liked by current user
  bool isPostLiked(String postId) {
    return getLikedPostIds().contains(postId);
  }

  /// Toggle like status for a post (add if not liked, remove if liked)
  Future<void> togglePostLike(String postId) async {
    final key = _getCurrentUserKey() + 'liked_posts';
    final likedPosts = prefs.getStringList(key) ?? [];

    if (likedPosts.contains(postId)) {
      likedPosts.remove(postId);
    } else {
      likedPosts.add(postId);
    }

    await prefs.setStringList(key, likedPosts);
  }

  /// Add a post to liked list for current user
  Future<void> addLikedPost(String postId) async {
    final key = _getCurrentUserKey() + 'liked_posts';
    final likedPosts = prefs.getStringList(key) ?? [];
    if (!likedPosts.contains(postId)) {
      likedPosts.add(postId);
      await prefs.setStringList(key, likedPosts);
    }
  }

  /// Remove a post from liked list for current user
  Future<void> removeLikedPost(String postId) async {
    final key = _getCurrentUserKey() + 'liked_posts';
    final likedPosts = prefs.getStringList(key) ?? [];
    if (likedPosts.contains(postId)) {
      likedPosts.remove(postId);
      await prefs.setStringList(key, likedPosts);
    }
  }

  /// Clear all liked posts for current user (for logout)
  Future<void> clearLikedPosts() async {
    final key = _getCurrentUserKey() + 'liked_posts';
    await prefs.remove(key);
  }

  /// Sync local likes with backend liked posts for current user
  /// This ensures consistency across devices
  Future<void> syncWithBackend(List<String> backendLikedPostIds) async {
    final key = _getCurrentUserKey() + 'liked_posts';
    await prefs.setStringList(key, backendLikedPostIds);
  }
}
