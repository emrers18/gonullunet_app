import 'package:cloud_firestore/cloud_firestore.dart';

class EventChatMessage {
  final String id;
  final String eventId;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String content;
  final Timestamp createdAt;

  EventChatMessage({
    required this.id,
    required this.eventId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    required this.createdAt,
  });

  factory EventChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EventChatMessage(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Bilinmeyen Kullanıcı',
      senderAvatarUrl: data['senderAvatarUrl'],
      content: data['content'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatarUrl': senderAvatarUrl,
      'content': content,
      'createdAt': createdAt,
    };
  }
}
