import 'package:gonullunet_app/l10n/app_localizations.dart';

/// Firestore'da kanonik (Türkçe) olarak saklanan kategori/tür değerlerini
/// yalnızca GÖSTERİM amacıyla aktif dile çevirir. Saklanan değerler değişmez.
class CategoryLocalizer {
  CategoryLocalizer._();

  /// Etkinlik kategorisini görüntü diline çevirir. Bilinmeyen değerler
  /// olduğu gibi döndürülür.
  static String category(AppLocalizations l10n, String value) {
    switch (value.trim().toLowerCase()) {
      case 'tümü':
      case 'tumu':
        return l10n.categoryAll;
      case 'genel':
        return l10n.categoryGeneral;
      case 'eğitim':
      case 'egitim':
        return l10n.categoryEducation;
      case 'çevre':
      case 'cevre':
        return l10n.categoryEnvironment;
      case 'sağlık':
      case 'saglik':
        return l10n.categoryHealth;
      case 'hayvan hakları':
      case 'hayvan haklari':
        return l10n.categoryAnimalRights;
      case 'afet':
        return l10n.categoryDisaster;
      case 'sanat':
        return l10n.categoryArt;
      case 'spor':
        return l10n.categorySports;
      case 'kültür':
      case 'kultur':
        return l10n.categoryCulture;
      default:
        return value;
    }
  }

  /// Etkinlik türünü (Etkinlik/Proje) görüntü diline çevirir.
  static String type(AppLocalizations l10n, String value) {
    switch (value.trim().toLowerCase()) {
      case 'etkinlik':
        return l10n.typeEvent;
      case 'proje':
        return l10n.typeProject;
      default:
        return value;
    }
  }

  /// Oyunlaştırma seviye başlığını görüntü diline çevirir.
  static String level(AppLocalizations l10n, String value) {
    switch (value.trim().toLowerCase()) {
      case 'gözlemci':
      case 'gozlemci':
        return l10n.levelObserver;
      case 'aktif':
      case 'aktif üye':
      case 'aktif uye':
        return l10n.levelActive;
      case 'öncü':
      case 'oncu':
        return l10n.levelPioneer;
      case 'usta':
        return l10n.levelMaster;
      case 'efsane':
        return l10n.levelLegend;
      default:
        return value;
    }
  }
}
