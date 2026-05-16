import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:gonullunet_app/models/event_model.dart';
import 'package:latlong2/latlong.dart';

import '../models/application_model.dart';
import '../services/functions_service.dart';
import '../services/image_compress_service.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FunctionsService _functionsService = FunctionsService();

  Stream<List<Event>> getEventsStream() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    return _firestore
        .collection('events')
        .where('startDate', isGreaterThanOrEqualTo: startOfToday)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    });
  }

  Future<List<Event>> getUpcomingEventsLimit({int limit = 5}) async {
    final now = DateTime.now();
    final snapshot = await _firestore
        .collection('events')
        .where('startDate', isGreaterThanOrEqualTo: now)
        .orderBy('startDate', descending: false)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
  }

  /// Paginated event fetch: returns (events, lastDocument) tuple.
  /// Pass [lastDocument] from the previous call to get the next page.
  Future<({List<Event> events, DocumentSnapshot? lastDoc})> getEventsPaginated({
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _firestore
        .collection('events')
        .where('startDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .orderBy('startDate', descending: false)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final events =
        snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    return (events: events, lastDoc: lastDoc);
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

  /// Etkinlik gorselini Storage'a yukler.
  /// Storage erisimi yoksa (Spark plani) null doner — etkinlik resimsiz olusturulur.
  Future<String?> uploadEventImage(File imageFile) async {
    try {
      final Uint8List? compressed =
          await ImageCompressService.compressFile(imageFile);

      final String fileName =
          'event_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('event_images/$fileName');

      final UploadTask uploadTask = compressed != null
          ? ref.putData(
              compressed,
              SettableMetadata(contentType: 'image/jpeg'),
            )
          : ref.putFile(imageFile);

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      // Storage erisimi yoksa (orn: Spark plani) sessizce null don
      if (kDebugMode) {
        debugPrint('[EventRepository] Gorsel yuklenemedi (atlanıyor): $e');
      }
      return null;
    }
  }

  /// Etkinlik olusturur. Gorsel yukleme basarisiz olursa resimsiz devam eder.
  /// Tum is mantigi (NGO kontrolu, Firestore yazma) Cloud Function uzerinden yapilir.
  Future<void> addEvent({
    required String title,
    required String description,
    required String location,
    required LatLng coordinates,
    required DateTime startDate,
    required DateTime endDate,
    required String category,
    required String type,
    String? imageUrl,
    int? quota,
  }) async {
    await _functionsService.createEvent(
      title: title,
      description: description,
      location: location,
      lat: coordinates.latitude,
      lng: coordinates.longitude,
      startDate: startDate,
      endDate: endDate,
      category: category,
      type: type,
      imageUrl: imageUrl,
      quota: quota,
    );
  }

  /// Etkinlige katilma/ayrilma islemini Cloud Function uzerinden yapar.
  /// XP odulu/cezasi sunucu tarafinda guvenle uygulanir.
  Future<void> toggleJoinEvent(String eventId, String userId) async {
    await _functionsService.toggleJoinEvent(eventId: eventId);
  }

  Future<String> getOrganizerName(String organizerId) async {
    try {
      final doc = await _firestore.collection('users').doc(organizerId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['stkName'] ?? data['name'] ?? 'Isimsiz Organizasyon';
      }
      return 'Bilinmeyen Kurum';
    } catch (e) {
      return 'Hata: Kurum Bulunamadi';
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

  /// Kullanicinin bu etkinlige daha once basvurup basvurmadigini kontrol eder.
  Future<bool> hasUserApplied(String eventId, String userId) async {
    final doc = await _firestore
        .collection('events')
        .doc(eventId)
        .collection('applications')
        .doc(userId)
        .get();
    return doc.exists;
  }

  Future<List<ApplicationModel>> getEventApplications(String eventId) async {
    final eventDoc = await _firestore.collection('events').doc(eventId).get();
    List<String> participants =
        List<String>.from(eventDoc.data()?['participants'] ?? []);

    final querySnapshot = await _firestore
        .collection('events')
        .doc(eventId)
        .collection('applications')
        .orderBy('appliedAt', descending: true)
        .get();

    List<ApplicationModel> applications = [];
    Set<String> processedUserIds = {};

    for (var doc in querySnapshot.docs) {
      var app = ApplicationModel.fromFirestore(doc);
      processedUserIds.add(app.userId);

      var userDoc = await _firestore.collection('users').doc(app.userId).get();
      if (userDoc.exists) {
        var userData = userDoc.data();
        app = app.copyWithUser(
          name: userData?['name'],
          surname: userData?['surname'],
          imageUrl: userData?['imageUrl'],
          xp: userData?['xp'],
        );
      }
      applications.add(app);
    }

    // Katilimcilar listesinde olup applications koleksiyonunda olmayanlar (eski veriler icin)
    for (String uid in participants) {
      if (!processedUserIds.contains(uid)) {
        var userDoc = await _firestore.collection('users').doc(uid).get();
        if (userDoc.exists) {
          var userData = userDoc.data();
          applications.add(ApplicationModel(
            id: uid,
            userId: uid,
            eventId: eventId,
            status: 'approved',
            appliedAt: (eventDoc.data()?['createdAt'] as Timestamp?) ??
                Timestamp.now(),
            userName: userData?['name'],
            userSurname: userData?['surname'],
            userImageUrl: userData?['imageUrl'],
          ));
        }
      }
    }

    return applications;
  }

  /// Basvuru durumunu gunceller. Organizator kontrolu ve XP hesabi
  /// Cloud Function tarafinda guvenle yapilir.
  Future<void> updateApplicationStatus(
      String eventId, String userId, String newStatus) async {
    await _functionsService.updateApplicationStatus(
      eventId: eventId,
      targetUserId: userId,
      newStatus: newStatus,
    );
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
