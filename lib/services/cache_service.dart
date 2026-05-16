import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences uzerinde JSON tabanli basit bir cache servisi.
///
/// Kullanim:
///   CacheService.writeList('events', events.map((e) => e.toJson()).toList());
///   final cached = CacheService.readList('events');
class CacheService {
  static SharedPreferences? _prefs;

  /// Uygulamanin basinda bir kez cagrilmali (main.dart'ta).
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    assert(_prefs != null, 'CacheService.init() cagrilmadi!');
    return _prefs!;
  }

  // -------------------------------------------------------------------------
  // Yaz
  // -------------------------------------------------------------------------

  /// [key] altina JSON listesi kaydeder.
  static Future<void> writeList(
      String key, List<Map<String, dynamic>> items) async {
    try {
      final encoded = jsonEncode(items);
      await _instance.setString(key, encoded);
    } catch (_) {
      // Cache yazma hatalari sessizce yoksayilir
    }
  }

  // -------------------------------------------------------------------------
  // Oku
  // -------------------------------------------------------------------------

  /// [key] altindaki JSON listesini okur. Cache yoksa bos liste doner.
  static List<Map<String, dynamic>> readList(String key) {
    try {
      final raw = _instance.getString(key);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  // -------------------------------------------------------------------------
  // Temizle
  // -------------------------------------------------------------------------

  /// Belirli bir cache anahtarini temizler (orn: logout sonrasi).
  static Future<void> clear(String key) async {
    await _instance.remove(key);
  }

  /// Tum cache'i temizler.
  static Future<void> clearAll() async {
    final keys = _instance.getKeys().where((k) =>
        k.startsWith('posts_') ||
        k == 'events' ||
        k == 'events_upcoming');
    for (final k in keys) {
      await _instance.remove(k);
    }
  }
}

/// Cache anahtarlari — tek merkezden yonetmek icin.
class CacheKeys {
  static const String postsNgo = 'posts_ngo';
  static const String postsVolunteer = 'posts_volunteer';
  static const String events = 'events';
  static const String eventsUpcoming = 'events_upcoming';
}
