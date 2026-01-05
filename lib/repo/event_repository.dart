import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gonullunet_app/models/event_model.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Event>> getEventsStream() {
    final now = DateTime.now();

    return _firestore
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    });
  }

  Future<bool> isUserNgo() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['userType'] == 'ngo';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleJoinEvent(String eventId, String userId) async {
    final eventRef = _firestore.collection('events').doc(eventId);
    final doc = await eventRef.get();

    if (doc.exists) {
      List<String> participants =
          List<String>.from(doc.data()?['participants'] ?? []);

      if (participants.contains(userId)) {
        // Zaten katılmışsa çıkar
        participants.remove(userId);
      } else {
        // Katılmamışsa ekle
        participants.add(userId);
      }

      await eventRef.update({'participants': participants});
    }
  }

  Future<String> getOrganizerName(String organizerId) async {
    try {
      final doc = await _firestore.collection('users').doc(organizerId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Öncelik stkName, yoksa name, yoksa varsayılan metin
        return data['stkName'] ?? data['name'] ?? 'İsimsiz Organizasyon';
      }
      return 'Bilinmeyen Kurum';
    } catch (e) {
      return 'Hata: Kurum Bulunamadı';
    }
  }
}
