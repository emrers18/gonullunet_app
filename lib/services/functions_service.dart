import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Cloud Functions ile auth işlemlerini yürüten servis sınıfı.
///
/// [registerUser]       — E-posta/şifre kaydı (Admin SDK tarafında yapılır).
/// [createUserProfile]  — Google Sign-In sonrası Firestore profili oluşturur.
class FunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─────────────────────────────────────────────────────────────────────────
  // registerUser
  // ─────────────────────────────────────────────────────────────────────────
  // Akış:
  //   1. CF: Firebase Auth'ta kullanıcı oluşturur, Firestore profilini yazar.
  //   2. İstemci: e-posta/şifre ile oturum açar.
  //   3. İstemci: sendEmailVerification() ile doğrulama e-postası gönderir.
  //   4. signOut() YAPILMAZ — SignUpPage başarılı kayıt sonrası
  //      kullanıcıyı manuel olarak EmailVerificationScreen'e yönlendirir.
  // ─────────────────────────────────────────────────────────────────────────
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

    // 1. Cloud Function: kullanıcıyı Auth + Firestore'da oluştur
    await callable.call(data);

    // 2. İstemci tarafında oturum aç
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 3. Sunucudan güncel kullanıcı durumunu çek
    await _auth.currentUser?.reload();
    final user = _auth.currentUser;

    // 4. Doğrulama e-postası gönder
    // Not: Admin SDK (CF tarafı) e-posta gönderemez; istemci SDK göndermeli.
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        if (kDebugMode) {
          print(
              '[FunctionsService] Doğrulama e-postası gönderildi: ${user.email}');
        }
      } on FirebaseAuthException catch (e) {
        // Hata loglanır ama kayıt iptal edilmez — kullanıcı EmailVerificationScreen'den tekrar gönderebilir
        if (kDebugMode) {
          print(
              '[FunctionsService] sendEmailVerification HATA — kod: ${e.code}, mesaj: ${e.message}');
        }
      } catch (e) {
        if (kDebugMode) {
          print(
              '[FunctionsService] sendEmailVerification beklenmeyen hata: $e');
        }
      }
    }

    // 5. signOut() YAPILMIYOR.
    // SignUpPage başarılı kayıt sonrası kullanıcıyı EmailVerificationScreen'e yönlendirir.
  }

  // ─────────────────────────────────────────────────────────────────────────
  // createUserProfile
  // Google Sign-In sonrası Firestore'da profil oluşturmak için çağrılır.
  // Kullanıcı zaten oturum açmış olmalıdır (JWT otomatik eklenir).
  // Returns true if a new profile was created, false if it already existed.
  // ─────────────────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────────────
  // createPost
  // ─────────────────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────────────
  // deleteUserAccount
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> deleteUserAccount() async {
    final callable = _functions.httpsCallable('deleteUserAccount');
    await callable.call();
  }
}
