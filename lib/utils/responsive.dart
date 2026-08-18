import 'package:flutter/material.dart';

/// Ekran boyutu kategorileri.
enum DeviceType { mobile, tablet, desktop }

/// Sabit piksel degerleri yerine kullanilan, MediaQuery tabanli responsive
/// yardimcilari. Tum boyutlar (font, ikon, bosluk, genislik/yukseklik)
/// buradaki metodlar uzerinden hesaplanmali; ekrana gore sabit `16.0` gibi
/// degerler yazmak yerine `Responsive.scale(context, 16)` kullanilmalidir.
///
/// Referans tasarim genisligi 375dp (standart telefon ekrani). Ekran bundan
/// daha genis/dar oldukca degerler orana gore olceklenir; [_minScale] ve
/// [_maxScale] ile kucuk telefonlarda asiri kucuk, tabletlerde asiri buyuk
/// gorunumler engellenir.
class Responsive {
  Responsive._();

  static const double _baseWidth = 375.0;
  static const double _minScale = 0.85;
  static const double _maxScale = 1.25;

  /// Bu genislikten (dp) itibaren tablet, [tabletBreakpoint]'ten itibaren
  /// desktop/genis ekran kabul edilir.
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// Sistem çentik/status bar/navigation bar boşlukları.
  static EdgeInsets safePadding(BuildContext context) =>
      MediaQuery.paddingOf(context);

  static DeviceType deviceType(BuildContext context) {
    final width = screenWidth(context);
    if (width >= tabletBreakpoint) return DeviceType.desktop;
    if (width >= mobileBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool isMobile(BuildContext context) =>
      deviceType(context) == DeviceType.mobile;
  static bool isTablet(BuildContext context) =>
      deviceType(context) == DeviceType.tablet;
  static bool isDesktop(BuildContext context) =>
      deviceType(context) == DeviceType.desktop;

  static double _scaleFactor(BuildContext context) =>
      (screenWidth(context) / _baseWidth).clamp(_minScale, _maxScale);

  /// Genişlik, ikon boyutu, boşluk, border radius gibi değerleri ekran
  /// genişliğine göre ölçekler. Örn: `Responsive.scale(context, 24)`.
  static double scale(BuildContext context, double value) =>
      value * _scaleFactor(context);

  /// Font boyutunu ekran genişliğine VE kullanıcının sistem yazı tipi
  /// büyütme ayarına (erişilebilirlik) göre ölçekler.
  /// Örn: `fontSize: Responsive.sp(context, 16)`.
  static double sp(BuildContext context, double fontSize) {
    final userTextScale =
        MediaQuery.textScalerOf(context).scale(1.0).clamp(0.85, 1.3);
    return fontSize * _scaleFactor(context) * userTextScale;
  }

  /// Ekran genişliğinin yüzdesi (0-100). Örn: `Responsive.wp(context, 50)`
  /// ekranın yarısı kadar genişlik verir.
  static double wp(BuildContext context, double percent) =>
      screenWidth(context) * percent / 100;

  /// Ekran yüksekliğinin yüzdesi (0-100).
  static double hp(BuildContext context, double percent) =>
      screenHeight(context) * percent / 100;

  /// Verilen boşluk değerlerini [scale] ile ölçekleyip [EdgeInsets] üretir.
  /// `all` verilirse diğer parametreler yok sayılır.
  static EdgeInsets padding(
    BuildContext context, {
    double all = 0,
    double horizontal = 0,
    double vertical = 0,
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    if (all != 0) return EdgeInsets.all(scale(context, all));
    return EdgeInsets.only(
      left: scale(context, left != 0 ? left : horizontal),
      top: scale(context, top != 0 ? top : vertical),
      right: scale(context, right != 0 ? right : horizontal),
      bottom: scale(context, bottom != 0 ? bottom : vertical),
    );
  }

  /// Ekran tipine göre farklı bir değer döndürür; belirtilmeyen üst
  /// kategoriler bir alttakine düşer (desktop yoksa tablet, o da yoksa
  /// mobile kullanılır).
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (deviceType(context)) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}
