import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gonullunet_app/models/event_chat_message_model.dart';
import 'package:gonullunet_app/models/event_model.dart';

class EventChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Retrieves events where the current user is approved
  Stream<List<Event>> getActiveChatsStream() {
    if (_userId == null) return const Stream.empty();

    return _firestore
        .collection('events')
        .where('approved_volunteers', arrayContains: _userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    });
  }

  /// Streams messages for a single event sorted by creation time
  Stream<List<EventChatMessage>> getEventMessagesStream(String eventId) {
    if (_userId == null) return const Stream.empty();

    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('chat')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventChatMessage.fromFirestore(doc))
          .toList();
    });
  }

  /// Sends a message inside the event's sub-collection
  Future<void> sendMessage({
    required String eventId,
    required String content,
    required String senderName,
    String? senderAvatarUrl,
  }) async {
    final userId = _userId;
    if (userId == null) return;

    final docRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('chat')
        .doc();

    final message = EventChatMessage(
      id: docRef.id,
      eventId: eventId,
      senderId: userId,
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
      content: content,
      createdAt: Timestamp.now(), // Fallback for local update
    );

    // Using server timestamp for accuracy on remote
    final data = message.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();

    await docRef.set(data);
  }
}
