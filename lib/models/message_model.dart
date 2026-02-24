import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String body;
  final String sender;
  final String senderEmail;
  final String receiver;
  final String receiverEmail;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;

  const MessageModel({
    required this.id,
    required this.body,
    required this.sender,
    required this.senderEmail,
    required this.receiver,
    required this.receiverEmail,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      body: json['message'] as String? ?? json['body'] as String? ?? '',
      sender: json['sender'] as String? ?? '',
      senderEmail: json['senderEmail'] as String? ?? '',
      receiver: json['receiver'] as String? ?? '',
      receiverEmail: json['receiverEmail'] as String? ?? '',
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(
              json['timestamp'] as String? ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] as bool? ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': body,
      'sender': sender,
      'senderEmail': senderEmail,
      'receiver': receiver,
      'receiverEmail': receiverEmail,
      'timestamp': timestamp,
      'isRead': isRead,
      'type': type.name,
    };
  }

  MessageModel copyWith({
    String? id,
    String? body,
    String? sender,
    String? senderEmail,
    String? receiver,
    String? receiverEmail,
    DateTime? timestamp,
    bool? isRead,
    MessageType? type,
  }) {
    return MessageModel(
      id: id ?? this.id,
      body: body ?? this.body,
      sender: sender ?? this.sender,
      senderEmail: senderEmail ?? this.senderEmail,
      receiver: receiver ?? this.receiver,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MessageModel(id: $id, body: $body, sender: $sender, timestamp: $timestamp)';
  }
}

enum MessageType {
  text,
  image,
  file,
  voice,
  video,
}
