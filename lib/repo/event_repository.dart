import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gonullunet_app/models/event_model.dart';
import 'package:latlong2/latlong.dart';

import '../models/application_model.dart';
import '../services/image_compress_service.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<Event>> getEventsStream() {
    return _firestore
        .collection('events')
        .where('startDate', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    });
  }

  /// Paginated event fetch: returns (events, lastDocument) tuple.
  /// Pass [lastDocument] from the previous call to get the next page.
  Future<({List<Event> events, DocumentSnapshot? lastDoc})> getEventsPaginated({
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _firestore
        .collection('events')
        .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .orderBy('startDate', descending: false)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final events = snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
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

  Future<String> uploadEventImage(File imageFile) async {
    // Görseli sıkıştır (max 1080px, %80 kalite)
    final Uint8List? compressed =
        await ImageCompressService.compressFile(imageFile);

    final String fileName =
        'event_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final Reference ref = _storage.ref().child('event_images/$fileName');

    // Sıkıştırılmış baytları yükle; başarısız olursa orijinal dosyayı kullan
    final UploadTask uploadTask = compressed != null
        ? ref.putData(
            compressed,
            SettableMetadata(contentType: 'image/jpeg'),
          )
        : ref.putFile(imageFile);

    final TaskSnapshot snapshot = await uploadTask;
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
      'approved_volunteers': [user.uid],
      'active': true,
      'isProject': type == 'Proje',
    });
  }

  Future<void> toggleJoinEvent(String eventId, String userId) async {
    final eventRef = _firestore.collection('events').doc(eventId);
    final appRef = eventRef.collection('applications').doc(userId);
    final doc = await eventRef.get();

    if (doc.exists) {
      List<String> participants =
          List<String>.from(doc.data()?['participants'] ?? []);

      final batch = _firestore.batch();

      if (participants.contains(userId)) {
        participants.remove(userId);
        batch.delete(appRef);
        batch.update(eventRef, {
          'participants': participants,
          'approved_volunteers': FieldValue.arrayRemove([userId])
        });
      } else {
        participants.add(userId);
        batch.set(appRef, {
          'userId': userId,
          'eventId': eventId,
          'status': 'approved',
          'appliedAt': FieldValue.serverTimestamp(),
        });
        batch.update(eventRef, {
          'participants': participants,
          'approved_volunteers': FieldValue.arrayUnion([userId])
        });
      }

      await batch.commit();
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

  /// Kullanıcının bu etkinliğe daha önce başvurup başvurmadığını kontrol eder.
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
    List<String> participants = List<String>.from(eventDoc.data()?['participants'] ?? []);

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
        );
      }
      applications.add(app);
    }

    // Olan participants(katılımcılar) listesinde olup applications koleksiyonunda olmayanlar (eski veriler için)
    for (String userId in participants) {
      if (!processedUserIds.contains(userId)) {
        var userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          var userData = userDoc.data();
          applications.add(ApplicationModel(
            id: userId,
            userId: userId,
            eventId: eventId,
            status: 'approved', // Katılımcıysa zaten onaylı gibidir
            appliedAt: (eventDoc.data()?['createdAt'] as Timestamp?) ?? Timestamp.now(),
            userName: userData?['name'],
            userSurname: userData?['surname'],
            userImageUrl: userData?['imageUrl'],
          ));
        }
      }
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
        'participants': FieldValue.arrayUnion([userId]),
        'approved_volunteers': FieldValue.arrayUnion([userId])
      });
    } else if (newStatus == 'rejected' || newStatus == 'pending') {
      batch.update(eventRef, {
        'participants': FieldValue.arrayRemove([userId]),
        'approved_volunteers': FieldValue.arrayRemove([userId])
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
