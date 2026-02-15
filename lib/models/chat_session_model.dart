import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSession {
  final String id;
  final String title;
  final Timestamp createdAt;
  final Timestamp lastMessageAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastMessageAt,
  });

  factory ChatSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatSession(
      id: doc.id,
      title: data['title'] ?? 'Yeni Sohbet',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      lastMessageAt: data['lastMessageAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createdAt': createdAt,
      'lastMessageAt': lastMessageAt,
    };
  }
}
