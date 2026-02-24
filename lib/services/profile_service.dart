import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

class ProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user profile by username
  static Future<UserModel?> getUserProfile(String username) async {
    try {
      final query = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromJson(query.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Get user posts
  static Stream<List<Map<String, dynamic>>> getUserPosts(String username) {
    try {
      return _firestore
          .collection('posts')
          .where('author', isEqualTo: username)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      }).handleError((error) {
        // Return empty list if posts collection doesn't exist or has issues
        return <Map<String, dynamic>>[];
      });
    } catch (e) {
      // Return empty stream if there's an error
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  // Create a new post
  static Future<void> createPost({
    required String author,
    required String body,
  }) async {
    try {
      await _firestore.collection('posts').add({
        'author': author,
        'body': body,
        'createdAt': DateTime.now(),
        'likes': <String>[],
        'comments': <Map<String, dynamic>>[],
      });
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get user statistics
  static Future<Map<String, int>> getUserStats(String username) async {
    try {
      int postsCount = 0;
      int friendsCount = 0;

      // Get posts count
      try {
        final postsQuery = await _firestore
            .collection('posts')
            .where('author', isEqualTo: username)
            .get();
        postsCount = postsQuery.docs.length;
      } catch (e) {
        // Posts collection might not exist, that's okay
        postsCount = 0;
      }

      // Get friends count
      try {
        final userQuery = await _firestore
            .collection(AppConstants.usersCollection)
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data();
          friendsCount = (userData['friends'] as List?)?.length ?? 0;
        }
      } catch (e) {
        // User might not exist, that's okay
        friendsCount = 0;
      }

      return {
        'posts': postsCount,
        'friends': friendsCount,
      };
    } catch (e) {
      // Return default stats if there's any error
      return {
        'posts': 0,
        'friends': 0,
      };
    }
  }

  // Delete a post
  static Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Like a post
  static Future<void> likePost(String postId, String username) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([username])
      });
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  // Unlike a post
  static Future<void> unlikePost(String postId, String username) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([username])
      });
    } catch (e) {
      throw Exception('Failed to unlike post: $e');
    }
  }
}
