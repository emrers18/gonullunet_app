import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:gonullunet_app/utils/app_messages.dart';

/// Firebase ve genel Dart istisnalarını, UI katmanında [AppMessages.resolve]
/// ile çevrilecek hata KODLARINA dönüştüren merkezi servis.
///
/// Cloud Function'dan gelen anlamlı (zaten okunabilir) mesajlar kod yerine
/// olduğu gibi döndürülür; [AppMessages.resolve] bilinmeyen kodları metin
/// olarak geçirir.
class FirebaseErrorTranslator {
  FirebaseErrorTranslator._();

  /// Herhangi bir istisnayı alıp bir hata kodu (veya dinamik mesaj) döndürür.
  static String translate(Object e) {
    if (e is FirebaseAuthException) {
      return _translateAuthException(e);
    }
    if (e is FirebaseFunctionsException) {
      return _translateFunctionsException(e);
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
        return AppErrorCodes.network;
      }
      if (msg.contains('timeout') || msg.contains('timed out')) {
        return AppErrorCodes.timeout;
      }
    }
    return AppErrorCodes.unexpected;
  }

  // --- Firebase Auth Hataları ---
  static String _translateAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AppErrorCodes.emailInUse;
      case 'invalid-email':
        return AppErrorCodes.invalidEmail;
      case 'weak-password':
        return AppErrorCodes.weakPassword;
      case 'wrong-password':
      case 'invalid-credential':
        return AppErrorCodes.wrongCredentials;
      case 'user-not-found':
        return AppErrorCodes.userNotFoundAuth;
      case 'user-disabled':
        return AppErrorCodes.userDisabled;
      case 'too-many-requests':
        return AppErrorCodes.tooManyAttempts;
      case 'network-request-failed':
        return AppErrorCodes.network;
      case 'requires-recent-login':
        return AppErrorCodes.requiresRecentLogin;
      case 'operation-not-allowed':
        return AppErrorCodes.operationNotAllowed;
      case 'expired-action-code':
        return AppErrorCodes.expiredActionCode;
      case 'invalid-action-code':
        return AppErrorCodes.invalidActionCode;
      default:
        return AppErrorCodes.authGeneric;
    }
  }

  // --- Firestore / Storage Hataları ---
  static String _translateFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return AppErrorCodes.permissionDenied;
      case 'unavailable':
      case 'network-request-failed':
        return AppErrorCodes.network;
      case 'not-found':
        return AppErrorCodes.notFound;
      case 'already-exists':
        return AppErrorCodes.alreadyExists;
      case 'resource-exhausted':
        // Cloud Function'dan gelen özel mesajı temizle ve döndür
        final cleanMsg = _getCleanMessage(e.message);
        if (cleanMsg.isNotEmpty &&
            !cleanMsg.toLowerCase().contains('resource-exhausted')) {
          return cleanMsg;
        }
        return AppErrorCodes.resourceExhausted;
      case 'cancelled':
        return AppErrorCodes.cancelled;
      case 'deadline-exceeded':
        return AppErrorCodes.timeout;
      case 'unauthenticated':
        return AppErrorCodes.unauthenticated;
      case 'object-not-found':
        return AppErrorCodes.fileNotFound;
      case 'quota-exceeded':
        return AppErrorCodes.quotaExceeded;
      default:
        return AppErrorCodes.server;
    }
  }

  // --- Cloud Functions Hataları ---
  static String _translateFunctionsException(FirebaseFunctionsException e) {
    // resource-exhausted durumunda mesajı direkt döndürmeye çalış
    if (e.code == 'resource-exhausted') {
      final cleanMsg = _getCleanMessage(e.message);
      if (cleanMsg.isNotEmpty) return cleanMsg;
    }

    return _translateFirebaseException(e);
  }

  static String _getCleanMessage(String? message) {
    if (message == null || message.isEmpty) return '';

    if (message.contains(']')) {
      return message.split(']').last.trim();
    }
    return message.trim();
  }
}
