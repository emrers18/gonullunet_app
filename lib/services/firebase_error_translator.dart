import 'package:firebase_auth/firebase_auth.dart';

/// Firebase ve genel Dart istisnalarını kullanıcı dostu
/// Türkçe mesajlara çeviren merkezi çeviri servisi.

class FirebaseErrorTranslator {
  FirebaseErrorTranslator._();

  /// Herhangi bir istisnayı alıp kullanıcıya gösterilebilecek
  /// Türkçe bir mesaj döndürür. Ham teknik detaylar gizlenir.
  static String translate(Object e) {
    if (e is FirebaseAuthException) {
      return _translateAuthException(e);
    }
    if (e is FirebaseException) {
      return _translateFirebaseException(e);
    }
    if (e is Exception) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') ||
          msg.contains('socket') ||
          msg.contains('connection') ||
          msg.contains('internet')) {
        return 'İnternet bağlantınızı kontrol edin.';
      }
      if (msg.contains('timeout') || msg.contains('timed out')) {
        return 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';
      }
    }
    return 'Beklenmedik bir hata oluştu. Lütfen tekrar deneyin.';
  }

  // --- Firebase Auth Hataları ---
  static String _translateAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'weak-password':
        return 'Şifre en az 6 karakter olmalıdır.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'user-not-found':
        return 'Bu e-posta adresine kayıtlı bir hesap bulunamadı.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış. Destek ile iletişime geçin.';
      case 'too-many-requests':
        return 'Çok fazla başarısız deneme. Lütfen bir süre bekleyin.';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin.';
      case 'requires-recent-login':
        return 'Bu işlem için tekrar giriş yapmanız gerekiyor.';
      case 'operation-not-allowed':
        return 'Bu giriş yöntemi şu an desteklenmiyor.';
      case 'expired-action-code':
        return 'Bağlantının süresi dolmuş. Lütfen yeni bir bağlantı isteyin.';
      case 'invalid-action-code':
        return 'Geçersiz doğrulama bağlantısı.';
      default:
        return 'Kimlik doğrulama hatası. Lütfen tekrar deneyin.';
    }
  }

  // --- Firestore / Storage Hataları ---
  static String _translateFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Bu işlem için yetkiniz bulunmuyor.';
      case 'unavailable':
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin.';
      case 'not-found':
        return 'İstenen veri bulunamadı.';
      case 'already-exists':
        return 'Bu kayıt zaten mevcut.';
      case 'resource-exhausted':
        return 'Sunucu yoğunluğu yüksek, lütfen daha sonra tekrar deneyin.';
      case 'cancelled':
        return 'İşlem iptal edildi.';
      case 'deadline-exceeded':
        return 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';
      case 'unauthenticated':
        return 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.';
      case 'object-not-found':
        return 'Dosya bulunamadı.';
      case 'quota-exceeded':
        return 'Depolama kotası aşıldı.';
      default:
        return 'Sunucu hatası oluştu. Lütfen tekrar deneyin.';
    }
  }
}
