import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Cloud Functions ile tum islemleri yurutuen servis sinifi.
///
/// Auth  : [registerUser], [createUserProfile], [deleteUserAccount]
/// Event : [createEvent], [updateApplicationStatus], [toggleJoinEvent]
/// Social: [toggleFollowNgo], [toggleLikePost], [deletePost]
class FunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // -------------------------------------------------------------------------
  // registerUser
  // -------------------------------------------------------------------------
  Future<void> registerUser({
    required String email,
    required String password,
    required String userType,
    String? name,
    String? surname,
    String? stkName,
  }) async {
    final callable = _functions.httpsCallable(
      'registerUser',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );

    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
      'userType': userType,
    };

    if (name != null) data['name'] = name;
    if (surname != null) data['surname'] = surname;
    if (stkName != null) data['stkName'] = stkName;

    await callable.call(data);

    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _auth.currentUser?.reload();
    final user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        if (kDebugMode) {
          print('[FunctionsService] Dogrulama e-postasi gonderildi: ${user.email}');
        }
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          print('[FunctionsService] sendEmailVerification HATA: ${e.code} - ${e.message}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('[FunctionsService] sendEmailVerification beklenmeyen hata: $e');
        }
      }
    }
  }

  // -------------------------------------------------------------------------
  // createUserProfile
  // -------------------------------------------------------------------------
  Future<bool> createUserProfile({
    required String userType,
    String? displayName,
    String? photoUrl,
  }) async {
    final callable = _functions.httpsCallable('createUserProfile');

    final result = await callable.call({
      'userType': userType,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });

    return result.data['created'] as bool? ?? false;
  }

  // -------------------------------------------------------------------------
  // createPost
  // -------------------------------------------------------------------------
  Future<String> createPost({
    required String title,
    required String description,
    String? imageUrl,
  }) async {
    final callable = _functions.httpsCallable('createPost');

    final result = await callable.call({
      'title': title,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });

    return result.data['postId'] as String;
  }

  // -------------------------------------------------------------------------
  // deleteUserAccount
  // -------------------------------------------------------------------------
  Future<void> deleteUserAccount() async {
    final callable = _functions.httpsCallable('deleteUserAccount');
    await callable.call();
  }

  // -------------------------------------------------------------------------
  // createEvent
  // NGO kontrolu + Firestore etkinlik olusturma.
  // Resim yukleme istemci tarafindan yapilir (imageUrl opsiyonel).
  // -------------------------------------------------------------------------
  Future<String> createEvent({
    required String title,
    required String description,
    required String location,
    required double lat,
    required double lng,
    required DateTime startDate,
    required DateTime endDate,
    required String category,
    required String type,
    String? imageUrl,
    int? quota,
  }) async {
    final callable = _functions.httpsCallable(
      'createEvent',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );

    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'location': location,
      'geoPoint': {'lat': lat, 'lng': lng},
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
      'category': category,
      'type': type,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (quota != null) 'quota': quota,
    };

    final result = await callable.call(data);
    return result.data['eventId'] as String;
  }

  // -------------------------------------------------------------------------
  // updateApplicationStatus
  // Organizator kontrolu + XP odulu/cezasi sunucu tarafinda.
  // -------------------------------------------------------------------------
  Future<void> updateApplicationStatus({
    required String eventId,
    required String targetUserId,
    required String newStatus,
  }) async {
    final callable = _functions.httpsCallable('updateApplicationStatus');
    await callable.call({
      'eventId': eventId,
      'targetUserId': targetUserId,
      'newStatus': newStatus,
    });
  }

  // -------------------------------------------------------------------------
  // toggleJoinEvent
  // Katilma/ayrilma + XP guvenligi sunucu tarafinda.
  // -------------------------------------------------------------------------
  Future<void> toggleJoinEvent({required String eventId}) async {
    final callable = _functions.httpsCallable('toggleJoinEvent');
    await callable.call({'eventId': eventId});
  }

  // -------------------------------------------------------------------------
  // toggleFollowNgo
  // -------------------------------------------------------------------------
  Future<void> toggleFollowNgo({required String ngoId}) async {
    final callable = _functions.httpsCallable('toggleFollowNgo');
    await callable.call({'ngoId': ngoId});
  }

  // -------------------------------------------------------------------------
  // toggleLikePost
  // -------------------------------------------------------------------------
  Future<void> toggleLikePost({required String postId}) async {
    final callable = _functions.httpsCallable('toggleLikePost');
    await callable.call({'postId': postId});
  }

  // -------------------------------------------------------------------------
  // deletePost
  // Sahiplik kontrolu + Firestore + Storage temizleme sunucu tarafinda.
  // -------------------------------------------------------------------------
  Future<void> deletePost({required String postId}) async {
    final callable = _functions.httpsCallable('deletePost');
    await callable.call({'postId': postId});
  }
}
