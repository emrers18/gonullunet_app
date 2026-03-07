class AppConstants {
  AppConstants._();

  /// Tüm etkinlik kategorileri — add_event_modal, event_filter_modal ve
  /// events_map_page tarafından ortak kullanılır.
  static const List<String> eventCategories = [
    'Genel',
    'Eğitim',
    'Çevre',
    'Sağlık',
    'Hayvan Hakları',
    'Afet',
    'Sanat',
    'Spor',
  ];

  /// Gönüllü ilgi alanları — edit_volunteer_profile_page tarafından kullanılır.
  static const List<String> volunteerInterests = [
    'Çevre',
    'Eğitim',
    'Hayvan Hakları',
    'Teknoloji',
    'Sanat',
    'Afet Yönetimi',
    'Sağlık',
    'Spor',
    'Sosyal Hizmet',
    'İnsan Hakları',
    'Kültür',
    'Gıda Bankası',
  ];

  /// Gönüllü yetenekleri — edit_volunteer_profile_page tarafından kullanılır.
  static const List<String> volunteerSkills = [
    'Fotoğrafçılık',
    'Grafik Tasarım',
    'İngilizce',
    'İlk Yardım',
    'Kodlama',
    'Şoförlük',
    'Video Düzenleme',
    'Sosyal Medya',
    'Yazarlık',
    'Tercümanlık',
    'Müzik',
    'Eğitmenlik',
    'Proje Yönetimi',
  ];
}
