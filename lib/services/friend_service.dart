import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

class FriendService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send friend request
  static Future<void> sendFriendRequest({
    required String fromUsername,
    required String toUsername,
  }) async {
    try {
      final batch = _firestore.batch();

      // Add to sender's sent requests
      final senderDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: fromUsername)
          .limit(1)
          .get();

      if (senderDoc.docs.isNotEmpty) {
        final senderRef = senderDoc.docs.first.reference;
        batch.update(senderRef, {
          'sentRequests': FieldValue.arrayUnion([toUsername])
        });
      }

      // Add to receiver's received requests
      final receiverDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: toUsername)
          .limit(1)
          .get();

      if (receiverDoc.docs.isNotEmpty) {
        final receiverRef = receiverDoc.docs.first.reference;
        batch.update(receiverRef, {
          'receivedRequests': FieldValue.arrayUnion([fromUsername])
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to send friend request: $e');
    }
  }

  // Accept friend request
  static Future<void> acceptFriendRequest({
    required String fromUsername,
    required String toUsername,
  }) async {
    try {
      final batch = _firestore.batch();

      // Remove from receiver's received requests and add to friends
      final receiverDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: toUsername)
          .limit(1)
          .get();

      if (receiverDoc.docs.isNotEmpty) {
        final receiverRef = receiverDoc.docs.first.reference;
        batch.update(receiverRef, {
          'receivedRequests': FieldValue.arrayRemove([fromUsername]),
          'friends': FieldValue.arrayUnion([fromUsername])
        });
      }

      // Remove from sender's sent requests and add to friends
      final senderDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: fromUsername)
          .limit(1)
          .get();

      if (senderDoc.docs.isNotEmpty) {
        final senderRef = senderDoc.docs.first.reference;
        batch.update(senderRef, {
          'sentRequests': FieldValue.arrayRemove([toUsername]),
          'friends': FieldValue.arrayUnion([toUsername])
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to accept friend request: $e');
    }
  }

  // Decline friend request
  static Future<void> declineFriendRequest({
    required String fromUsername,
    required String toUsername,
  }) async {
    try {
      final batch = _firestore.batch();

      // Remove from receiver's received requests
      final receiverDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: toUsername)
          .limit(1)
          .get();

      if (receiverDoc.docs.isNotEmpty) {
        final receiverRef = receiverDoc.docs.first.reference;
        batch.update(receiverRef, {
          'receivedRequests': FieldValue.arrayRemove([fromUsername])
        });
      }

      // Remove from sender's sent requests
      final senderDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: fromUsername)
          .limit(1)
          .get();

      if (senderDoc.docs.isNotEmpty) {
        final senderRef = senderDoc.docs.first.reference;
        batch.update(senderRef, {
          'sentRequests': FieldValue.arrayRemove([toUsername])
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to decline friend request: $e');
    }
  }

  // Remove friend
  static Future<void> removeFriend({
    required String fromUsername,
    required String toUsername,
  }) async {
    try {
      final batch = _firestore.batch();

      // Remove from both users' friends list
      final fromDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: fromUsername)
          .limit(1)
          .get();

      if (fromDoc.docs.isNotEmpty) {
        final fromRef = fromDoc.docs.first.reference;
        batch.update(fromRef, {
          'friends': FieldValue.arrayRemove([toUsername])
        });
      }

      final toDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: toUsername)
          .limit(1)
          .get();

      if (toDoc.docs.isNotEmpty) {
        final toRef = toDoc.docs.first.reference;
        batch.update(toRef, {
          'friends': FieldValue.arrayRemove([fromUsername])
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to remove friend: $e');
    }
  }

  // Get user's friends
  static Future<List<UserModel>> getUserFriends({
    required String username,
  }) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userDoc.docs.isEmpty) {
        return [];
      }

      final userData = userDoc.docs.first.data();
      final friendsList = List<String>.from(userData['friends'] ?? []);

      if (friendsList.isEmpty) {
        return [];
      }

      final friendsDocs = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', whereIn: friendsList)
          .get();

      return friendsDocs.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user friends: $e');
    }
  }

  // Get pending friend requests
  static Future<List<UserModel>> getPendingRequests({
    required String username,
  }) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userDoc.docs.isEmpty) {
        return [];
      }

      final userData = userDoc.docs.first.data();
      final receivedRequests =
          List<String>.from(userData['receivedRequests'] ?? []);

      if (receivedRequests.isEmpty) {
        return [];
      }

      final requestsDocs = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', whereIn: receivedRequests)
          .get();

      return requestsDocs.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending requests: $e');
    }
  }

  // Check if users are friends
  static Future<bool> areFriends({
    required String username1,
    required String username2,
  }) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: username1)
          .limit(1)
          .get();

      if (userDoc.docs.isEmpty) {
        return false;
      }

      final userData = userDoc.docs.first.data();
      final friendsList = List<String>.from(userData['friends'] ?? []);

      return friendsList.contains(username2);
    } catch (e) {
      throw Exception('Failed to check friendship status: $e');
    }
  }
}
