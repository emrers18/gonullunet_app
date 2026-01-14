import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gonullunet_app/models/event_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/application_model.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<Event>> getEventsStream() {
    return _firestore
        .collection('events')
        .orderBy('startDate', descending: false)
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

  Future<String> uploadEventImage(File imageFile) async {
    String fileName = 'event_${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference ref = _storage.ref().child('event_images/$fileName');
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> addEvent({
    required String title,
    required String description,
    required String location,
    required LatLng coordinates,
    required DateTime startDate,
    required DateTime endDate,
    required String category,
    required String type, // 'Etkinlik' veya 'Proje'
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı oturumu bulunamadı.");

    await _firestore.collection('events').add({
      'title': title,
      'description': description,
      'location': location,
      'geoPoint': GeoPoint(coordinates.latitude, coordinates.longitude),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'imageUrl': imageUrl ?? '',
      'category': category,
      'type': type,
      'organizerId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'participants': [],
      'active': true,
      'isProject': type == 'Proje',
    });
  }

  Future<void> toggleJoinEvent(String eventId, String userId) async {
    final eventRef = _firestore.collection('events').doc(eventId);
    final doc = await eventRef.get();

    if (doc.exists) {
      List<String> participants =
          List<String>.from(doc.data()?['participants'] ?? []);

      if (participants.contains(userId)) {
        participants.remove(userId);
      } else {
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

  Future<void> applyToEvent(String eventId, String userId) async {
    // events/{eventId}/applications/{userId} yolu
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('applications')
        .doc(userId)
        .set({
      'userId': userId,
      'eventId': eventId,
      'status': 'pending',
      'appliedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<ApplicationModel>> getEventApplications(String eventId) async {
    final querySnapshot = await _firestore
        .collection('events')
        .doc(eventId)
        .collection('applications')
        .orderBy('appliedAt', descending: true)
        .get();

    List<ApplicationModel> applications = [];

    for (var doc in querySnapshot.docs) {
      var app = ApplicationModel.fromFirestore(doc);

      var userDoc = await _firestore.collection('users').doc(app.userId).get();
      if (userDoc.exists) {
        var userData = userDoc.data();
        app = app.copyWithUser(
          name: userData?['name'],
          surname: userData?['surname'],
          imageUrl: userData?['imageUrl'],
        );
      }
      applications.add(app);
    }
    return applications;
  }

  //Stk tarafı
  Future<void> updateApplicationStatus(
      String eventId, String userId, String newStatus) async {
    final batch = _firestore.batch();

    // basvuru durumunu guncelleme
    var appRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('applications')
        .doc(userId);
    batch.update(appRef, {'status': newStatus});

    var eventRef = _firestore.collection('events').doc(eventId);

    if (newStatus == 'approved') {
      batch.update(eventRef, {
        'participants': FieldValue.arrayUnion([userId])
      });
    } else if (newStatus == 'rejected' || newStatus == 'pending') {
      batch.update(eventRef, {
        'participants': FieldValue.arrayRemove([userId])
      });
    }

    await batch.commit();
  }

  Future<String?> getUserApplicationStatus(
      String eventId, String userId) async {
    final doc = await _firestore
        .collection('events')
        .doc(eventId)
        .collection('applications')
        .doc(userId)
        .get();

    if (doc.exists) {
      return doc.data()?['status'] as String?;
    }
    return null;
  }
}
