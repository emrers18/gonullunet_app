import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama dilini yöneten cubit. Seçilen dil SharedPreferences'ta saklanır.
class LocaleCubit extends Cubit<Locale> {
  static const String _prefsKey = 'app_locale';

  /// Uygulamanın desteklediği diller.
  static const List<Locale> supportedLocales = [
    Locale('tr'),
    Locale('en'),
  ];

  /// Desteklenmeyen bir sistem dili için varsayılan.
  static const Locale _fallbackLocale = Locale('tr');

  /// Kullanıcı daha önce manuel bir dil seçmediyse, telefonun sistem
  /// diliyle açılır (desteklenmiyorsa Türkçe'ye düşer).
  LocaleCubit() : super(_resolveSystemLocale());

  static Locale _resolveSystemLocale() {
    final systemCode = PlatformDispatcher.instance.locale.languageCode;
    return supportedLocales.firstWhere(
      (l) => l.languageCode == systemCode,
      orElse: () => _fallbackLocale,
    );
  }

  /// Kayıtlı (kullanıcının elle seçtiği) bir dil varsa onu yükler; bu her
  /// zaman sistem diline göre yapılan varsayım tahmininin önüne geçer.
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && supportedLocales.any((l) => l.languageCode == code)) {
      emit(Locale(code));
    }
  }

  /// Dili değiştirir ve kalıcı olarak kaydeder.
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.any((l) => l.languageCode == locale.languageCode)) {
      return;
    }
    emit(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}
