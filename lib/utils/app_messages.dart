import 'package:flutter/widgets.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';

/// İş mantığı katmanı (cubit/repo/service) BuildContext taşımadığı için
/// kullanıcıya gösterilecek hataları doğrudan çeviremez. Bunun yerine bu
/// dosyadaki sabit KODLARDAN birini döndürürler; UI katmanı [resolve] ile
/// kodu aktif dile çevirir. Kod listede yoksa (ör. sunucudan gelen dinamik
/// mesaj) metin olduğu gibi gösterilir.
class AppErrorCodes {
  AppErrorCodes._();

  static const network = 'err_network';
  static const timeout = 'err_timeout';
  static const unexpected = 'err_unexpected';
  static const unexpectedRetry = 'err_unexpected_retry';
  static const emailInUse = 'err_email_in_use';
  static const invalidEmail = 'err_invalid_email';
  static const weakPassword = 'err_weak_password';
  static const wrongCredentials = 'err_wrong_credentials';
  static const userNotFoundAuth = 'err_user_not_found_auth';
  static const userDisabled = 'err_user_disabled';
  static const tooManyAttempts = 'err_too_many_attempts';
  static const requiresRecentLogin = 'err_requires_recent_login';
  static const operationNotAllowed = 'err_operation_not_allowed';
  static const expiredActionCode = 'err_expired_action_code';
  static const invalidActionCode = 'err_invalid_action_code';
  static const authGeneric = 'err_auth_generic';
  static const permissionDenied = 'err_permission_denied';
  static const notFound = 'err_not_found';
  static const alreadyExists = 'err_already_exists';
  static const resourceExhausted = 'err_resource_exhausted';
  static const cancelled = 'err_cancelled';
  static const unauthenticated = 'err_unauthenticated';
  static const fileNotFound = 'err_file_not_found';
  static const quotaExceeded = 'err_quota_exceeded';
  static const server = 'err_server';
  static const chatHistoryLoad = 'err_chat_history_load';
  static const chatDelete = 'err_chat_delete';
  static const messagesLoad = 'err_messages_load';
  static const locationFailed = 'err_location_failed';
  static const locationNotFound = 'err_location_not_found';
  static const searchFailed = 'err_search_failed';
  static const addressDetail = 'err_address_detail';
  static const unknownLocation = 'err_unknown_location';
  static const notificationsLoad = 'err_notifications_load';
  static const userDataNotFound = 'err_user_data_not_found';
  static const followFailed = 'err_follow_failed';
  static const signupFailed = 'err_signup_failed';
  static const eventNgoOnly = 'err_event_ngo_only';
  static const eventLoginRequired = 'err_event_login_required';
  static const eventFillAll = 'err_event_fill_all';
  static const eventProfileNotFound = 'err_event_profile_not_found';
  static const eventCreateFailed = 'err_event_create_failed';
  static const messageSend = 'err_message_send';
  static const aiDailyLimit = 'err_ai_daily_limit';
  static const aiBusy = 'err_ai_busy';
  static const aiTimeout = 'err_ai_timeout';
  static const aiUnreachable = 'err_ai_unreachable';
  static const aiOpTimeout = 'err_ai_op_timeout';
  static const imageUpload = 'err_image_upload';
  static const sessionNotFound = 'err_session_not_found';
}

/// Bir hata kodunu (veya dinamik mesajı) aktif dile çevirir.
class AppMessages {
  AppMessages._();

  static String resolve(BuildContext context, String codeOrMessage) {
    final l10n = AppLocalizations.of(context);
    switch (codeOrMessage) {
      case AppErrorCodes.network:
        return l10n.errNetwork;
      case AppErrorCodes.timeout:
        return l10n.errTimeout;
      case AppErrorCodes.unexpected:
        return l10n.errUnexpected;
      case AppErrorCodes.unexpectedRetry:
        return l10n.errUnexpectedRetry;
      case AppErrorCodes.emailInUse:
        return l10n.errEmailInUse;
      case AppErrorCodes.invalidEmail:
        return l10n.errInvalidEmailAddr;
      case AppErrorCodes.weakPassword:
        return l10n.errWeakPassword;
      case AppErrorCodes.wrongCredentials:
        return l10n.errWrongCredentials;
      case AppErrorCodes.userNotFoundAuth:
        return l10n.errUserNotFoundAuth;
      case AppErrorCodes.userDisabled:
        return l10n.errUserDisabled;
      case AppErrorCodes.tooManyAttempts:
        return l10n.errTooManyAttempts;
      case AppErrorCodes.requiresRecentLogin:
        return l10n.errRequiresRecentLogin;
      case AppErrorCodes.operationNotAllowed:
        return l10n.errOperationNotAllowed;
      case AppErrorCodes.expiredActionCode:
        return l10n.errExpiredActionCode;
      case AppErrorCodes.invalidActionCode:
        return l10n.errInvalidActionCode;
      case AppErrorCodes.authGeneric:
        return l10n.errAuthGeneric;
      case AppErrorCodes.permissionDenied:
        return l10n.errPermissionDenied;
      case AppErrorCodes.notFound:
        return l10n.errNotFound;
      case AppErrorCodes.alreadyExists:
        return l10n.errAlreadyExists;
      case AppErrorCodes.resourceExhausted:
        return l10n.errResourceExhausted;
      case AppErrorCodes.cancelled:
        return l10n.errCancelled;
      case AppErrorCodes.unauthenticated:
        return l10n.errUnauthenticated;
      case AppErrorCodes.fileNotFound:
        return l10n.errFileNotFound;
      case AppErrorCodes.quotaExceeded:
        return l10n.errQuotaExceeded;
      case AppErrorCodes.server:
        return l10n.errServer;
      case AppErrorCodes.chatHistoryLoad:
        return l10n.errChatHistoryLoad;
      case AppErrorCodes.chatDelete:
        return l10n.errChatDelete;
      case AppErrorCodes.messagesLoad:
        return l10n.errMessagesLoad;
      case AppErrorCodes.locationFailed:
        return l10n.errLocationFailed;
      case AppErrorCodes.locationNotFound:
        return l10n.errLocationNotFound;
      case AppErrorCodes.searchFailed:
        return l10n.errSearchFailed;
      case AppErrorCodes.addressDetail:
        return l10n.errAddressDetail;
      case AppErrorCodes.unknownLocation:
        return l10n.errUnknownLocation;
      case AppErrorCodes.notificationsLoad:
        return l10n.errNotificationsLoad;
      case AppErrorCodes.userDataNotFound:
        return l10n.errUserDataNotFound;
      case AppErrorCodes.followFailed:
        return l10n.errFollowFailed;
      case AppErrorCodes.signupFailed:
        return l10n.errSignupFailed;
      case AppErrorCodes.eventNgoOnly:
        return l10n.errEventNgoOnly;
      case AppErrorCodes.eventLoginRequired:
        return l10n.errEventLoginRequired;
      case AppErrorCodes.eventFillAll:
        return l10n.errEventFillAll;
      case AppErrorCodes.eventProfileNotFound:
        return l10n.errEventProfileNotFound;
      case AppErrorCodes.eventCreateFailed:
        return l10n.errEventCreateFailed;
      case AppErrorCodes.messageSend:
        return l10n.errMessageSend;
      case AppErrorCodes.aiDailyLimit:
        return l10n.errAiDailyLimit;
      case AppErrorCodes.aiBusy:
        return l10n.errAiBusy;
      case AppErrorCodes.aiTimeout:
        return l10n.errAiTimeout;
      case AppErrorCodes.aiUnreachable:
        return l10n.errAiUnreachable;
      case AppErrorCodes.aiOpTimeout:
        return l10n.errAiOpTimeout;
      case AppErrorCodes.imageUpload:
        return l10n.errImageUpload;
      case AppErrorCodes.sessionNotFound:
        return l10n.errSessionNotFound;
      default:
        // Bilinmeyen kod: sunucudan gelen dinamik mesaj olabilir, olduğu gibi göster.
        return codeOrMessage;
    }
  }
}
