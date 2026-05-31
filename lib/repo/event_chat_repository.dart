import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gonullunet_app/models/event_chat_message_model.dart';
import 'package:gonullunet_app/models/event_model.dart';
import 'package:gonullunet_app/services/functions_service.dart';

class EventChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FunctionsService _functionsService = FunctionsService();

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

  /// Sends a message via Cloud Function (approved volunteer check on server).
  /// [senderName] and [senderAvatarUrl] are now resolved server-side.
  Future<void> sendMessage({
    required String eventId,
    required String content,
    required String senderName,
    String? senderAvatarUrl,
  }) async {
    await _functionsService.sendEventChatMessage(
      eventId: eventId,
      content: content,
    );
  }
}
