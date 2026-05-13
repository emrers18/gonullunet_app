import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'functions_service.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FunctionsService _functionsService = FunctionsService();

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  //Login
  Future<void> signIn({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  //Logout
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  //Delete Account
  Future<void> deleteAccount() async {
    await _functionsService.deleteUserAccount();
    await signOut();
  }

  Future<UserCredential?> signInWithGoogle() async {
    // 1. Initialize (Required in 7.x)
    await _googleSignIn.initialize();

    // 2. Kullanıcıya Google hesabı seçtir
    final googleUser = await _googleSignIn.authenticate();
    // 3. Kimlik doğrulama detaylarını al (idToken)
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    // 4. Yetkilendirme detaylarını al (accessToken)
    final clientAuth = await googleUser.authorizationClient.authorizeScopes([
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ]);

    // 5. Firebase için yeni bir credential (kimlik bilgisi) oluştur
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: clientAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 6. Firebase ile giriş yap
    return await _firebaseAuth.signInWithCredential(credential);
  }

  /// Google Sign-In sonrası profil oluşturma — Cloud Function'a delege edilir.
  /// CF idempotent'tir: profil zaten varsa hiçbir şey yazmaz.
  Future<void> createProfile({
    required User user,
    required String userType,
    String? displayName,
    String? photoUrl,
  }) async {
    await _functionsService.createUserProfile(
      userType: userType,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  /// Kullanıcı profilinin Firestore'da var olup olmadığını kontrol eder.
  /// Google Sign-In flow'unda rol seçimi kararı için kullanılır.
  /// Kullanıcı Firebase'de oturum açmış olmak zorunda değil — sadece UID gerekir.
  Future<bool> userExists(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.exists;
  }
}
