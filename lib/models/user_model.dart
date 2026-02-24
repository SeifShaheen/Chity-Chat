import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String username;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime lastSeen;
  final bool isOnline;
  final List<String> friends;
  final List<String> sentRequests;
  final List<String> receivedRequests;
  final String? fcmToken;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.username,
    this.profileImageUrl,
    required this.createdAt,
    required this.lastSeen,
    this.isOnline = false,
    this.friends = const [],
    this.sentRequests = const [],
    this.receivedRequests = const [],
    this.fcmToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      lastSeen: json['lastSeen'] is Timestamp
          ? (json['lastSeen'] as Timestamp).toDate()
          : DateTime.parse(
              json['lastSeen'] as String? ?? DateTime.now().toIso8601String()),
      isOnline: json['isOnline'] as bool? ?? false,
      friends: List<String>.from(json['friends'] as List? ?? []),
      sentRequests: List<String>.from(json['sentRequests'] as List? ?? []),
      receivedRequests:
          List<String>.from(json['receivedRequests'] as List? ?? []),
      fcmToken: json['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'lastSeen': lastSeen,
      'isOnline': isOnline,
      'friends': friends,
      'sentRequests': sentRequests,
      'receivedRequests': receivedRequests,
      'fcmToken': fcmToken,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? username,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastSeen,
    bool? isOnline,
    List<String>? friends,
    List<String>? sentRequests,
    List<String>? receivedRequests,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      friends: friends ?? this.friends,
      sentRequests: sentRequests ?? this.sentRequests,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, username: $username)';
  }

  // Helper methods
  bool isFriendWith(String username) {
    return friends.contains(username);
  }

  bool hasSentRequestTo(String username) {
    return sentRequests.contains(username);
  }

  bool hasReceivedRequestFrom(String username) {
    return receivedRequests.contains(username);
  }

  int get friendsCount => friends.length;
  int get pendingRequestsCount => receivedRequests.length;
}
