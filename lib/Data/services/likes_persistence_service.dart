import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting liked post IDs locally and syncing with backend
/// This ensures likes persist across app restarts and devices
class LikesPersistenceService {
  final SharedPreferences prefs;
  static const String _likedPostsKey = 'liked_posts';

  LikesPersistenceService(this.prefs);

  /// Get all liked post IDs from local storage
  List<String> getLikedPostIds() {
    return prefs.getStringList(_likedPostsKey) ?? [];
  }

  /// Check if a specific post is liked
  bool isPostLiked(String postId) {
    return getLikedPostIds().contains(postId);
  }

  /// Toggle like status for a post (add if not liked, remove if liked)
  Future<void> togglePostLike(String postId) async {
    final likedPosts = getLikedPostIds();

    if (likedPosts.contains(postId)) {
      likedPosts.remove(postId);
    } else {
      likedPosts.add(postId);
    }

    await prefs.setStringList(_likedPostsKey, likedPosts);
  }

  /// Add a post to liked list
  Future<void> addLikedPost(String postId) async {
    final likedPosts = getLikedPostIds();
    if (!likedPosts.contains(postId)) {
      likedPosts.add(postId);
      await prefs.setStringList(_likedPostsKey, likedPosts);
    }
  }

  /// Remove a post from liked list
  Future<void> removeLikedPost(String postId) async {
    final likedPosts = getLikedPostIds();
    if (likedPosts.contains(postId)) {
      likedPosts.remove(postId);
      await prefs.setStringList(_likedPostsKey, likedPosts);
    }
  }

  /// Clear all liked posts (for logout)
  Future<void> clearLikedPosts() async {
    await prefs.remove(_likedPostsKey);
  }

  /// Sync local likes with backend liked posts
  /// This ensures consistency across devices
  Future<void> syncWithBackend(List<String> backendLikedPostIds) async {
    await prefs.setStringList(_likedPostsKey, backendLikedPostIds);
  }
}
