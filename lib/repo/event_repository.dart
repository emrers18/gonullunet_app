import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gonullunet_app/models/event_model.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Event>> getEventsStream() {
    return _firestore
        .collection('events')
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
}
