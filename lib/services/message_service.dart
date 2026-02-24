import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../constants/app_constants.dart';

class MessageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a message
  static Future<void> sendMessage({
    required MessageModel message,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.messagesCollection)
          .add(message.toJson());
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages between two users
  static Stream<List<MessageModel>> getMessages({
    required String senderEmail,
    required String receiverEmail,
  }) {
    try {
      return _firestore
          .collection(AppConstants.messagesCollection)
          .where('senderEmail', isEqualTo: senderEmail)
          .where('receiverEmail', isEqualTo: receiverEmail)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  // Get all messages for a user (both sent and received)
  static Stream<List<MessageModel>> getAllMessagesForUser({
    required String userEmail,
  }) {
    try {
      return _firestore
          .collection(AppConstants.messagesCollection)
          .where('senderEmail', isEqualTo: userEmail)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get user messages: $e');
    }
  }

  // Mark message as read
  static Future<void> markMessageAsRead({
    required String messageId,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.messagesCollection)
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  // Mark all messages as read for a conversation
  static Future<void> markConversationAsRead({
    required String senderEmail,
    required String receiverEmail,
  }) async {
    try {
      final batch = _firestore.batch();

      final unreadMessages = await _firestore
          .collection(AppConstants.messagesCollection)
          .where('senderEmail', isEqualTo: senderEmail)
          .where('receiverEmail', isEqualTo: receiverEmail)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark conversation as read: $e');
    }
  }

  // Delete a message
  static Future<void> deleteMessage({
    required String messageId,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.messagesCollection)
          .doc(messageId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  // Get unread message count for a user
  static Future<int> getUnreadMessageCount({
    required String userEmail,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.messagesCollection)
          .where('receiverEmail', isEqualTo: userEmail)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get unread message count: $e');
    }
  }

  // Get last message between two users
  static Future<MessageModel?> getLastMessage({
    required String senderEmail,
    required String receiverEmail,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.messagesCollection)
          .where('senderEmail', isEqualTo: senderEmail)
          .where('receiverEmail', isEqualTo: receiverEmail)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return MessageModel.fromJson(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get last message: $e');
    }
  }
}
