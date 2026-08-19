// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'GönüllüNet';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'İngilizce';

  @override
  String get languageOption => 'Dil Seçeneği';

  @override
  String get selectLanguage => 'Dil Seçin';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get ok => 'Tamam';

  @override
  String get close => 'Kapat';

  @override
  String comingSoon(String feature) {
    return '$feature yakında eklenecek!';
  }

  @override
  String errorOccurred(String error) {
    return 'Hata oluştu: $error';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get accountAndActions => 'Hesap & İşlemler';

  @override
  String get accountSettings => 'Hesap Ayarları';

  @override
  String get myPosts => 'Gönderilerim';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get events => 'Etkinlikler';

  @override
  String get myPublishedEvents => 'Yayınladığım Etkinlikler';

  @override
  String get myJoinedEvents => 'Katıldığım Etkinlikler';

  @override
  String get application => 'Uygulama';

  @override
  String get generalSettings => 'Genel Ayarlar';

  @override
  String get about => 'Hakkında';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get signOutConfirm => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String version(String version) {
    return 'Versiyon $version';
  }

  @override
  String get corporateMember => 'Kurumsal Üye';

  @override
  String get volunteerMember => 'Gönüllü Üye';

  @override
  String nextLevel(Object xp) {
    return 'Sonraki Seviye: $xp XP';
  }

  @override
  String get xpInfo =>
      'Etkinliklere katılarak, paylaşım yaparak ve etkileşim kurarak XP kazanabilirsin.\nRozetler: Gözlemci (0+), Aktif (100+), Öncü (500+), Usta (1500+), Efsane (5000+)';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get changePassword => 'Şifre Değiştir';

  @override
  String get notificationSettings => 'Bildirim Ayarları';

  @override
  String get accountSettingsSection => 'Hesap Ayarları';

  @override
  String get deleteAccount => 'Hesabımı Sil';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get aboutUs => 'Hakkımızda';

  @override
  String get rateApp => 'Uygulamayı Değerlendir';

  @override
  String get deleteAccountConfirm =>
      'Hesabınızı silmek istediğinize emin misiniz?';

  @override
  String get cancelUpper => 'İPTAL';

  @override
  String get yesDelete => 'EVET, SİL';

  @override
  String get onboardTitle1 => 'GönüllüNet\'e\nHoş Geldin';

  @override
  String get onboardDesc1 =>
      'Çevrendeki iyilik hareketlerini keşfet, topluluğa katıl ve fark yaratmaya hemen başla.';

  @override
  String get onboardTitle2 => 'Etkinlikleri\nKeşfet';

  @override
  String get onboardDesc2 =>
      'Sana en yakın gönüllülük etkinliklerini harita üzerinde bul ve ilgi alanına göre filtrele.';

  @override
  String get onboardTitle3 => 'Birlikte\nGüçlüyüz';

  @override
  String get onboardDesc3 =>
      'STK\'lar ve gönüllülerle bir araya gelerek büyük değişimlerin bir parçası ol.';

  @override
  String get onboardSkip => 'Atla';

  @override
  String get onboardStart => 'Keşfetmeye Başla';

  @override
  String get onboardContinue => 'Devam Et';

  @override
  String get emailEmpty => 'E-posta boş bırakılamaz.';

  @override
  String get invalidEmailFormat => 'Geçersiz e-posta formatı.';

  @override
  String get invalidEmail => 'Geçersiz e-posta adresi.';

  @override
  String get passwordEmpty => 'Şifre boş bırakılamaz.';

  @override
  String get passwordWeak =>
      'Şifre zayıf. En az 8 karakter, büyük/küçük harf, rakam ve özel karakter içermelidir.';

  @override
  String get nameEmpty => 'Ad boş bırakılamaz.';

  @override
  String get surnameEmpty => 'Soyad boş bırakılamaz.';

  @override
  String get ngoNameEmpty => 'STK adı boş bırakılamaz.';

  @override
  String get almostReady => 'Neredeyse Hazır!';

  @override
  String get selectUserType => 'Lütfen kullanıcı türünüzü seçerek devam edin.';

  @override
  String get roleVolunteer => 'Gönüllü';

  @override
  String get roleVolunteerDesc => 'Etkinlik ara ve katıl';

  @override
  String get roleNgo => 'STK';

  @override
  String get roleNgoDesc => 'Kurum profili oluştur';

  @override
  String get welcomeBack => 'Tekrar Hoş Geldin!';

  @override
  String get loginSubtitle => 'İyilik yolculuğuna kaldığın yerden devam et.';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get emailHint => 'merhaba@ornek.com';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get forgotPassword => 'Şifremi Unuttum?';

  @override
  String get login => 'Giriş Yap';

  @override
  String get noAccount => 'Hesabın yok mu?';

  @override
  String get signUp => 'Kayıt Ol';

  @override
  String get signupVolunteerTagline => 'Gönüllü Ol, Etkinliklere Katıl';

  @override
  String get signupNgoTagline => 'Kurum Portalı';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get signupVolunteerSubtitle =>
      'Gönüllü olmak için bilgilerinizi giriniz.';

  @override
  String get signupNgoSubtitle => 'Gönüllülerle buluşmak için katılın.';

  @override
  String get firstName => 'Ad';

  @override
  String get lastName => 'Soyad';

  @override
  String get emailAddress => 'E-posta Adresi';

  @override
  String get ngoName => 'STK Adı';

  @override
  String get alreadyHaveAccount => 'Zaten bir hesabın var mı?';

  @override
  String get loginAction => 'Giriş yap';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navDiscover => 'Keşfet';

  @override
  String get navOrganizations => 'Kurumlar';

  @override
  String get navMessages => 'Mesajlar';

  @override
  String get navProfile => 'Profil';

  @override
  String get assistant => 'Asistan';

  @override
  String get homeGreeting => 'Merhaba, 👋';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get noPostsYet =>
      'Henüz hiç gönderi yok.\nSTK\'lar burada paylaşım yapacak.';

  @override
  String get ngoPostsSection => 'STK PAYLAŞIMLARI';

  @override
  String get upcomingEvents => 'YAKLAŞAN ETKİNLİKLER';

  @override
  String get seeAll => 'Tümünü Gör';

  @override
  String get seeAllShort => 'Hepsini Gör';

  @override
  String get defaultVolunteerName => 'Gönüllü';

  @override
  String get defaultNgoName => 'STK';

  @override
  String get errorTitle => 'Bir Hata Oluştu';

  @override
  String get checkingProfile => 'Profil Bilgileri Kontrol Ediliyor...';

  @override
  String get userSessionNotFound => 'Kullanıcı oturumu bulunamadı.';

  @override
  String get verificationEmailResent =>
      'Doğrulama e-postası tekrar gönderildi.';

  @override
  String get tooManyRequests =>
      'Çok fazla istek gönderildi. Lütfen birkaç dakika bekleyin.';

  @override
  String emailSendFailed(String error) {
    return 'E-posta gönderilemedi: $error';
  }

  @override
  String unexpectedError(String error) {
    return 'Beklenmeyen hata: $error';
  }

  @override
  String get verifyYourEmail => 'E-postanızı Doğrulayın';

  @override
  String get cancelRegistrationTooltip => 'Kayıt işlemini iptal et';

  @override
  String get verificationLinkSent =>
      'Bu adrese bir doğrulama bağlantısı gönderdik. Bağlantıya tıkladıktan sonra uygulama otomatik olarak devam edecek.';

  @override
  String get countdownExpired => 'doldu';

  @override
  String get countdownRemaining => 'kalan';

  @override
  String get checkInbox =>
      'E-posta kutunuzu kontrol edin. Doğrulama bağlantısına tıkladıktan sonra otomatik olarak yönlendirileceksiniz.';

  @override
  String get timeUp => 'Süre Doldu!';

  @override
  String get linkExpiredDesc =>
      'Doğrulama bağlantısının süresi geçti. Aşağıdaki butona basarak yeni bir bağlantı gönderebilirsiniz.';

  @override
  String get sending => 'Gönderiliyor...';

  @override
  String get sendNewLink => 'Yeni Bağlantı Gönder';

  @override
  String get resendLink => 'Bağlantıyı Yeniden Gönder';

  @override
  String resendIn(Object seconds) {
    return 'Yeniden Gönder ($seconds s)';
  }

  @override
  String get cancelReturnLogin => 'Vazgeç — Giriş ekranına dön';

  @override
  String get allEvents => 'Tüm Etkinlikler';

  @override
  String get noEventsFound =>
      'Henüz hiç etkinlik yok\nveya filtreye uygun sonuç bulunamadı.';

  @override
  String get clearFilters => 'Filtreleri Temizle';

  @override
  String get eventsSubtitle => 'Gönüllü etkinlikleri keşfet ve katıl';

  @override
  String get filter => 'Filtre';

  @override
  String get fullScreen => 'Tam Ekran';

  @override
  String statUpcoming(Object count) {
    return '$count Yaklaşan';
  }

  @override
  String statOnMap(Object count) {
    return '$count Haritada';
  }

  @override
  String imagePickFailed(String error) {
    return 'Resim seçilemedi: $error';
  }

  @override
  String get titleEmpty => 'Başlık boş bırakılamaz.';

  @override
  String get selectLocationOnMap => 'Lütfen haritadan bir konum seçin.';

  @override
  String get selectAllTimes =>
      'Lütfen başlangıç, bitiş ve son başvuru zamanlarını seçin.';

  @override
  String get endBeforeStart => 'Bitiş tarihi başlangıçtan önce olamaz!';

  @override
  String get lastApplyAfterStart =>
      'Son başvuru tarihi başlangıç tarihinden sonra olamaz!';

  @override
  String get lastApplyInPast => 'Son başvuru tarihi geçmiş bir zaman olamaz!';

  @override
  String get selectPlaceholder => 'Seçiniz';

  @override
  String get eventCreatedSuccess => 'İçerik başarıyla oluşturuldu!';

  @override
  String get newEvent => 'Yeni Etkinlik';

  @override
  String get publish => 'Yayınla';

  @override
  String get eventTitleHint => 'Etkinlik Başlığı';

  @override
  String get eventDescriptionHint => 'Etkinlik hakkında bilgi ver...';

  @override
  String get type => 'Tür';

  @override
  String get category => 'Kategori';

  @override
  String get quotaOptional => 'Kontenjan (Opsiyonel)';

  @override
  String get location => 'Konum';

  @override
  String get change => 'Değiştir';

  @override
  String get selectLocationFromMap => 'Haritadan Konum Seç';

  @override
  String get startLabel => 'Başlangıç';

  @override
  String get endLabel => 'Bitiş';

  @override
  String get lastApplyDateLabel => 'Son Başvuru Tarihi';

  @override
  String get addImageOptional => 'Görsel Ekle (Opsiyonel)';

  @override
  String get categoryAll => 'Tümü';

  @override
  String get categoryGeneral => 'Genel';

  @override
  String get categoryEducation => 'Eğitim';

  @override
  String get categoryEnvironment => 'Çevre';

  @override
  String get categoryHealth => 'Sağlık';

  @override
  String get categoryAnimalRights => 'Hayvan Hakları';

  @override
  String get categoryDisaster => 'Afet';

  @override
  String get categoryArt => 'Sanat';

  @override
  String get categorySports => 'Spor';

  @override
  String get categoryCulture => 'Kültür';

  @override
  String get typeEvent => 'Etkinlik';

  @override
  String get typeProject => 'Proje';

  @override
  String get eventFull => 'Dolu';

  @override
  String get beFirstToJoin => 'İlk sen ol!';

  @override
  String get filterTitle => 'Filtrele';

  @override
  String get clear => 'Temizle';

  @override
  String get cityLabel => 'Şehir';

  @override
  String get eventCategoryLabel => 'Etkinlik Türü';

  @override
  String get selectDateRange => 'Tarih Aralığı Seç';

  @override
  String get apply => 'Uygula';

  @override
  String get organizer => 'Düzenleyen';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get applicationStat => 'Başvuru';

  @override
  String get participantStat => 'Katılımcı';

  @override
  String personCount(Object count) {
    return '$count Kişi';
  }

  @override
  String get soFar => 'Şimdiye kadar';

  @override
  String get manageApplications => 'Başvuruları Yönet';

  @override
  String get eventExpired => 'Bu etkinliğin süresi doldu';

  @override
  String get applicationClosed => 'Başvuru süresi doldu';

  @override
  String get applyNow => 'Hemen Başvur';

  @override
  String get leaveEvent => 'Etkinlikten Ayrıl';

  @override
  String get applicationPending => 'Başvuru Bekleniyor (İptal)';

  @override
  String get leaveEventConfirm =>
      'Etkinlikten ayrılmak istediğinize emin misiniz?';

  @override
  String get cancelApplicationConfirm =>
      'Başvurunuzu iptal etmek istediğinize emin misiniz?';

  @override
  String get applicationSubmitted => 'Başvurunuz iletildi, onay bekleniyor!';

  @override
  String get projectLetterPrompt =>
      'Bu projeye başvurmak için lütfen niyetinizi belirten bir mektup yazın. Başvurunuzun onaylanması için bu mektup kurum tarafından incelenecektir.';

  @override
  String get letterHint => 'Niyetinizi bu alana detaylıca yazınız...';

  @override
  String get send => 'Gönder';

  @override
  String get dateLabel => 'Tarih';

  @override
  String get details => 'Detaylar';

  @override
  String get quotaFull => 'Kontenjan Dolu';

  @override
  String get intentLetter => 'Niyet Mektubu';

  @override
  String charCountLabel(Object count, Object min) {
    return '$count / $min karakter';
  }

  @override
  String lastApplyPrefix(String date) {
    return 'Son Başvuru: $date';
  }

  @override
  String get searchEvent => 'Etkinlik ara...';

  @override
  String get shrink => 'Küçült';

  @override
  String get noEventsForCriteria => 'Bu kritere uygun etkinlik bulunamadı.';

  @override
  String get examine => 'İncele';

  @override
  String participantCount(Object count) {
    return '$count katılımcı';
  }

  @override
  String get userNotFound => 'Kullanıcı bulunamadı';

  @override
  String get noEventsPublished => 'Henüz etkinlik yayınlamadınız.';

  @override
  String get noEventsJoined => 'Henüz bir etkinliğe katılmadınız.';

  @override
  String get searchLocationHint => 'Konum ara...';

  @override
  String get selectingLocation => 'Konum seçiliyor...';

  @override
  String get selectedAddress => 'Seçilen Adres';

  @override
  String get addressFinding => 'Adres bulunuyor...';

  @override
  String get confirmLocation => 'Konumu Onayla';

  @override
  String likeCountLabel(Object count) {
    return '$count Beğeni';
  }

  @override
  String commentCountLabel(Object count) {
    return '$count Yorum';
  }

  @override
  String get like => 'Beğen';

  @override
  String get comment => 'Yorum';

  @override
  String get descriptionEmpty => 'Açıklama boş bırakılamaz.';

  @override
  String get checkAllBoxes => 'Lütfen tüm onay kutucuklarını işaretleyin.';

  @override
  String get imageUploadFailed => 'Resim yüklenemedi, URL boş döndü.';

  @override
  String get postShared => 'Gönderi başarıyla paylaşıldı.';

  @override
  String get newPost => 'Yeni Gönderi';

  @override
  String get share => 'Paylaş';

  @override
  String get addTitle => 'Başlık Ekle';

  @override
  String get whatsHappening => 'Neler oluyor?';

  @override
  String get addPhoto => 'Fotoğraf Ekle';

  @override
  String get consentAccuracy =>
      'Paylaştığım içeriğin doğruluğundan sorumluyum.';

  @override
  String get consentRules =>
      'Topluluk kurallarına uygun hareket edeceğimi taahhüt ederim.';

  @override
  String get noComments => 'Henüz yorum yok. İlk yorumu sen yap!';

  @override
  String get commentHint => 'Yorumunuzu yazın...';

  @override
  String get filterByCity => 'Şehre Göre Filtrele';

  @override
  String get searchCity => 'Şehir ara...';

  @override
  String get noCityInfo => 'Henüz şehir bilgisi mevcut değil.';

  @override
  String get noCityMatch => 'Eşleşen şehir bulunamadı.';

  @override
  String get allOrganizations => 'Tüm Kurumlar';

  @override
  String get ngosSubtitle => 'Sivil toplum kuruluşlarını keşfet ve destek ol';

  @override
  String get noResults => 'Sonuç bulunamadı.';

  @override
  String get ngoDetail => 'STK Detayı';

  @override
  String get civilSocietyOrg => 'Sivil Toplum Kuruluşu';

  @override
  String get unfollow => 'Takibi Bırak';

  @override
  String get follow => 'Takip Et';

  @override
  String get contact => 'İletişim';

  @override
  String get followers => 'Takipçi';

  @override
  String get tabDescription => 'Açıklama';

  @override
  String get tabPosts => 'Gönderiler';

  @override
  String get contactInfo => 'İletişim Bilgileri';

  @override
  String get noEventsShort => 'Henüz etkinlik yok.';

  @override
  String get noPostsShared => 'Henüz paylaşım yapılmamış.';

  @override
  String get locationUnspecified => 'Lokasyon Belirtilmemiş';

  @override
  String get statEvent => 'Etkinlik';

  @override
  String get statScore => 'Puan';

  @override
  String get ourMission => 'Misyonumuz';

  @override
  String get ourVision => 'Vizyonumuz';

  @override
  String get groupChatsSubtitle => 'Katıldığın etkinliklerin grup sohbetleri';

  @override
  String get connectionError => 'Bağlantı Hatası';

  @override
  String get noActiveChats => 'Henüz aktif sohbet yok';

  @override
  String get joinEventsForChats =>
      'Etkinliklere katılarak\ngrup sohbetlerine dahil ol!';

  @override
  String get discoverEvents => 'Etkinlikleri Keşfet';

  @override
  String get userInfoUnavailable => 'Kullanıcı bilgisi alınamadı.';

  @override
  String genericErrorMessage(String message) {
    return 'Bir hata oluştu:\n$message';
  }

  @override
  String get deleteAll => 'Tümünü Sil';

  @override
  String get noNotifications => 'Henüz bildiriminiz yok.';

  @override
  String get deleteAllConfirm =>
      'Tüm bildirimleri silmek istediğinize emin misiniz?';

  @override
  String get allNotificationsDeleted => 'Tüm bildirimler silindi';

  @override
  String get volunteerAi => 'Gönüllü AI';

  @override
  String get smartAssistant => 'Akıllı Asistan';

  @override
  String get aiGreeting => 'Merhaba! 👋';

  @override
  String get aiIntro =>
      'Ben GönüllüNet AI Asistanı.\nErasmus+, gönüllülük projeleri ve STK\'lar\nhakkında sorularınızı yanıtlayabilirim.';

  @override
  String get quickStart => 'HIZLI BAŞLANGIÇ';

  @override
  String get qErasmus => 'Erasmus+ nedir?';

  @override
  String get qHowVolunteer => 'Nasıl gönüllü olabilirim?';

  @override
  String get qHowJoinNgo => 'STK\'lara nasıl katılırım?';

  @override
  String get qNearbyEvents => 'Bana yakın etkinlikler';

  @override
  String get qNearbyEventsFull =>
      'Bana yakın gönüllülük etkinlikleri nelerdir?';

  @override
  String get deleteChat => 'Sohbeti Sil';

  @override
  String get deleteChatConfirm =>
      'Bu sohbet kalıcı olarak silinecek. Emin misiniz?';

  @override
  String get smartVolunteerAssistant => 'Akıllı Gönüllülük Asistanı';

  @override
  String get pastChats => 'GEÇMİŞ SOHBETLER';

  @override
  String get aiAssistantTitle => 'GönüllüNet AI Asistanı';

  @override
  String get aiHistoryIntro =>
      'Erasmus+, gönüllülük projeleri, STK\'lar ve\nsosyal sorumluluk hakkında bilgi almak için\nyeni bir sohbet başlatın.';

  @override
  String get startNewChat => 'Yeni Sohbet Başlat';

  @override
  String get askNewQuestion => 'AI asistanına yeni bir soru sor';

  @override
  String get messageHint => 'Mesaj yazın...';

  @override
  String get noMessages => 'Henüz hiç mesaj yok.\nİlk mesajı sen gönder!';

  @override
  String get editProfile => 'Profilini Düzenle';

  @override
  String get profileUpdatedSuccess => 'Profil başarıyla güncellendi!';

  @override
  String get profileUpdating => 'Profil güncelleniyor...';

  @override
  String get profileVisibilityNote =>
      'Profil bilgileriniz başvuru yapacağınız etkinliğin sahibi STK tarafından görüntülenecektir.';

  @override
  String get aboutMe => 'Hakkımda';

  @override
  String get aboutMeHint =>
      'Kendinizi tanıtın, motivasyonunuzu ve neden gönüllülük yaptığınızı yazın...';

  @override
  String get interests => 'İlgi Alanları';

  @override
  String get skills => 'Yetenekler';

  @override
  String get birthDate => 'Doğum Tarihi';

  @override
  String get selectBirthDate => 'Doğum tarihinizi seçin';

  @override
  String get educationProfession => 'Eğitim Durumu / Meslek';

  @override
  String get educationHint => 'Örn: Üniversite Öğrencisi, Psikoloji Bölümü';

  @override
  String get locationCityDistrict => 'Konum (Şehir / İlçe)';

  @override
  String get locationExampleHint => 'Örn: Kadıköy, İstanbul';

  @override
  String get phoneNumber => 'Telefon Numarası';

  @override
  String get ngoNameEmptyError => 'STK Adı boş olamaz.';

  @override
  String get editNgoProfile => 'STK Profilini Düzenle';

  @override
  String get tapToChangeLogo => 'Logoyu değiştirmek için dokunun';

  @override
  String get cityExampleHint => 'Kadıköy, İstanbul';

  @override
  String get ngoDescriptionHint =>
      'Kuruluşunuz hakkında kısa bir açıklama yazın...';

  @override
  String get visionLabel => 'Vizyon';

  @override
  String get missionLabel => 'Misyon';

  @override
  String get visionHint => 'Vizyonunuz...';

  @override
  String get missionHint => 'Misyonunuz...';

  @override
  String get locationEmptyError => 'Konum boş olamaz.';

  @override
  String get phoneEmptyError => 'Telefon boş olamaz.';

  @override
  String get visionEmptyError => 'Vizyon boş olamaz.';

  @override
  String get missionEmptyError => 'Misyon boş olamaz.';

  @override
  String get socialMediaLinks => 'Sosyal Medya Bağlantıları';

  @override
  String get facebookLabel => 'Facebook (Opsiyonel)';

  @override
  String get facebookHint => 'https://facebook.com/sayfaniz';

  @override
  String get instagramLabel => 'Instagram (Opsiyonel)';

  @override
  String get instagramHint => 'https://instagram.com/hesabiniz';

  @override
  String get twitterLabel => 'Twitter / X (Opsiyonel)';

  @override
  String get twitterHint => 'https://x.com/hesabiniz';

  @override
  String get linkedinLabel => 'LinkedIn (Opsiyonel)';

  @override
  String get linkedinHint => 'https://linkedin.com/company/kuruluşunuz';

  @override
  String get couldNotOpenLink => 'Bağlantı açılamadı.';

  @override
  String get completeNgoProfileTitle => 'Profilinizi Tamamlayın';

  @override
  String get completeNgoProfileNotice =>
      'Uygulamayı kullanmaya başlamadan önce STK profilinizi tamamlamanız gerekiyor. Devam etmek için aşağıdaki tüm bilgileri doldurup kaydedin.';

  @override
  String get applicantProfile => 'Başvuran Profili';

  @override
  String get applicationLetter => 'Başvuru Niyet Mektubu';

  @override
  String get notSpecified => 'Belirtilmemiş';

  @override
  String ageLabel(Object age) {
    return '$age yaş';
  }

  @override
  String get errNetwork => 'İnternet bağlantınızı kontrol edin.';

  @override
  String get errTimeout => 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';

  @override
  String get errUnexpected =>
      'Beklenmedik bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get errUnexpectedRetry =>
      'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get errEmailInUse => 'Bu e-posta adresi zaten kullanılıyor.';

  @override
  String get errInvalidEmailAddr => 'Geçersiz e-posta adresi.';

  @override
  String get errWeakPassword => 'Şifre en az 6 karakter olmalıdır.';

  @override
  String get errWrongCredentials => 'E-posta veya şifre hatalı.';

  @override
  String get errUserNotFoundAuth =>
      'Bu e-posta adresine kayıtlı bir hesap bulunamadı.';

  @override
  String get errUserDisabled =>
      'Bu hesap devre dışı bırakılmış. Destek ile iletişime geçin.';

  @override
  String get errTooManyAttempts =>
      'Çok fazla başarısız deneme. Lütfen bir süre bekleyin.';

  @override
  String get errRequiresRecentLogin =>
      'Bu işlem için tekrar giriş yapmanız gerekiyor.';

  @override
  String get errOperationNotAllowed => 'Bu giriş yöntemi şu an desteklenmiyor.';

  @override
  String get errExpiredActionCode =>
      'Bağlantının süresi dolmuş. Lütfen yeni bir bağlantı isteyin.';

  @override
  String get errInvalidActionCode => 'Geçersiz doğrulama bağlantısı.';

  @override
  String get errAuthGeneric =>
      'Kimlik doğrulama hatası. Lütfen tekrar deneyin.';

  @override
  String get errPermissionDenied => 'Bu işlem için yetkiniz bulunmuyor.';

  @override
  String get errNotFound => 'İstenen veri bulunamadı.';

  @override
  String get errAlreadyExists => 'Bu kayıt zaten mevcut.';

  @override
  String get errResourceExhausted =>
      'Limitinize ulaştınız veya sunucu şu an çok yoğun.';

  @override
  String get errCancelled => 'İşlem iptal edildi.';

  @override
  String get errUnauthenticated =>
      'Oturum süreniz doldu. Lütfen tekrar giriş yapın.';

  @override
  String get errFileNotFound => 'Dosya bulunamadı.';

  @override
  String get errQuotaExceeded => 'Depolama kotası aşıldı.';

  @override
  String get errServer => 'Sunucu hatası oluştu. Lütfen tekrar deneyin.';

  @override
  String get errChatHistoryLoad => 'Sohbet geçmişi yüklenemedi.';

  @override
  String get errChatDelete => 'Sohbet silinemedi.';

  @override
  String get errMessagesLoad => 'Mesajlar yüklenemedi.';

  @override
  String get errLocationFailed => 'Konum alınamadı.';

  @override
  String get errLocationNotFound => 'Konum bulunamadı.';

  @override
  String get errSearchFailed => 'Arama sırasında hata oluştu.';

  @override
  String get errAddressDetail => 'Adres detayı alınamadı';

  @override
  String get errUnknownLocation => 'Bilinmeyen Konum';

  @override
  String get errNotificationsLoad => 'Bildirimler alınamadı.';

  @override
  String get errUserDataNotFound => 'Kullanıcı verisi bulunamadı.';

  @override
  String get errFollowFailed => 'Takip işlemi başarısız.';

  @override
  String get errSignupFailed => 'Kayıt sırasında bir hata oluştu.';

  @override
  String get errEventNgoOnly =>
      'Etkinlik oluşturmak için STK hesabınız olmalıdır.';

  @override
  String get errEventLoginRequired =>
      'Bu işlemi yapmak için giriş yapmanız gerekiyor.';

  @override
  String get errEventFillAll => 'Lütfen tüm alanları doldurun.';

  @override
  String get errEventProfileNotFound => 'Kullanıcı profili bulunamadı.';

  @override
  String get errEventCreateFailed =>
      'Etkinlik oluşturulamadı. Lütfen tekrar deneyin.';

  @override
  String get errMessageSend => 'Mesaj gönderilirken bir hata oluştu.';

  @override
  String get errAiDailyLimit =>
      'Bugünlük soru limitine ulaştın. Yarın tekrar görüşmek üzere! 🚀';

  @override
  String get errAiBusy =>
      'Şu an çok yoğunum, lütfen bir dakika sonra tekrar dener misin? ☕';

  @override
  String get errAiTimeout =>
      'Yanıt vermem biraz uzun sürdü, internetini kontrol edip tekrar dener misin? ⏳';

  @override
  String get errAiUnreachable =>
      'Sunucuya şu an ulaşılamıyor, lütfen daha sonra tekrar dene. 🛠️';

  @override
  String get errAiOpTimeout =>
      'İşlem zaman aşımına uğradı, lütfen tekrar dene. ⏳';

  @override
  String get errImageUpload => 'Resim yükleme hatası.';

  @override
  String get errSessionNotFound => 'Kullanıcı oturumu bulunamadı.';

  @override
  String get aboutAppName => 'GönüllüNet';

  @override
  String get aboutTagline => 'Birlikte iyilik için';

  @override
  String get aboutDescription =>
      'GönüllüNet; gönüllüleri ve sivil toplum kuruluşlarını bir araya getiren bir gönüllülük platformudur. Çevrendeki etkinlikleri keşfet, başvur, grup sohbetlerine katıl ve toplulukla birlikte fark yarat.';

  @override
  String get aboutContact => 'İletişim';

  @override
  String get aboutContactEmail => 'gonullunet@gmail.com';

  @override
  String get aboutRights => '© 2025 GönüllüNet. Tüm hakları saklıdır.';

  @override
  String get aboutMadeWith => 'Sevgiyle geliştirildi ❤️';

  @override
  String get notifPushTitle => 'Anlık Bildirimler';

  @override
  String get notifPushSubtitle => 'Tüm bildirimleri aç veya kapat';

  @override
  String get notifEventsTitle => 'Etkinlik Bildirimleri';

  @override
  String get notifEventsSubtitle => 'Yeni etkinlikler ve hatırlatmalar';

  @override
  String get notifApplicationsTitle => 'Başvuru Bildirimleri';

  @override
  String get notifApplicationsSubtitle => 'Başvuru durumu güncellemeleri';

  @override
  String get notifMessagesTitle => 'Mesaj Bildirimleri';

  @override
  String get notifMessagesSubtitle => 'Grup sohbeti mesajları';

  @override
  String get notifAnnouncementsTitle => 'Duyurular';

  @override
  String get notifAnnouncementsSubtitle => 'Genel duyurular ve haberler';

  @override
  String get notifSavedHint => 'Tercihleriniz bu cihazda saklanır.';

  @override
  String changePasswordConfirm(String email) {
    return 'Şifrenizi sıfırlamak için $email adresine bir bağlantı göndereceğiz. Devam edilsin mi?';
  }

  @override
  String get passwordResetSent =>
      'Şifre sıfırlama bağlantısı e-postanıza gönderildi.';

  @override
  String get emailUnavailable =>
      'Hesabınıza ait bir e-posta adresi bulunamadı.';

  @override
  String get privacyIntro =>
      'Gizliliğiniz bizim için önemlidir. Bu politika, GönüllüNet\'i kullanırken hangi verileri topladığımızı ve nasıl kullandığımızı açıklar.';

  @override
  String get privacyDataTitle => 'Topladığımız Veriler';

  @override
  String get privacyDataBody =>
      'Hesap bilgileriniz (ad, e-posta, profil bilgileri), oluşturduğunuz gönderi ve etkinlikler ile konum tercihleriniz gibi uygulamayı kullanmak için sağladığınız verileri toplarız.';

  @override
  String get privacyUsageTitle => 'Verilerin Kullanımı';

  @override
  String get privacyUsageBody =>
      'Verilerinizi yalnızca hizmeti sunmak, etkinlik başvurularını yönetmek ve deneyiminizi iyileştirmek için kullanırız. Verileriniz izniniz olmadan üçüncü taraflarla pazarlama amacıyla paylaşılmaz.';

  @override
  String get privacySecurityTitle => 'Güvenlik';

  @override
  String get privacySecurityBody =>
      'Verileriniz Firebase altyapısında güvenli biçimde saklanır. Hesabınızı dilediğiniz zaman uygulama üzerinden silebilirsiniz.';

  @override
  String get privacyContactTitle => 'İletişim';

  @override
  String privacyContactBody(String email) {
    return 'Gizlilik ile ilgili sorularınız için bizimle iletişime geçebilirsiniz: $email';
  }

  @override
  String get privacyLastUpdated => 'Son güncelleme: Haziran 2025';

  @override
  String get rateAppFailed => 'Mağaza açılamadı.';

  @override
  String get educationProfessionShort => 'Eğitim / Meslek';

  @override
  String get volunteerLevel => 'Gönüllü Seviyesi';

  @override
  String get applications => 'Başvurular';

  @override
  String get phone => 'Telefon';

  @override
  String get colApplicationStatus => 'Başvuru Durumu';

  @override
  String get colApplicationDate => 'Başvuru Tarihi';

  @override
  String get statusApproved => 'Onaylandı';

  @override
  String get statusRejected => 'Reddedildi';

  @override
  String get statusPending => 'Bekliyor';

  @override
  String get excelCreateFailedException => 'Excel oluşturulamadı';

  @override
  String excelCreated(String path) {
    return 'Excel dosyası oluşturuldu: $path';
  }

  @override
  String excelCreateError(String error) {
    return 'Excel oluşturulamadı: $error';
  }

  @override
  String get noApprovedApplications => 'Onaylanmış başvuru bulunamadı.';

  @override
  String get participationListTitle => 'ETKİNLİK KATILIM LİSTESİ';

  @override
  String createdDateLabel(String date) {
    return 'Oluşturma Tarihi: $date';
  }

  @override
  String totalApprovedParticipants(Object count) {
    return 'Toplam Onaylı Katılımcı: $count';
  }

  @override
  String get colFullName => 'Ad Soyad';

  @override
  String pdfPageLabel(Object current, Object total) {
    return 'Sayfa $current / $total';
  }

  @override
  String pdfCreateError(String error) {
    return 'PDF oluşturulamadı: $error';
  }

  @override
  String get exportToExcel => 'Excel\'e Aktar';

  @override
  String get participationListPdf => 'Katılım Listesi (PDF)';

  @override
  String get noApplications => 'Henüz başvuru yok.';

  @override
  String get unnamed => 'İsimsiz';

  @override
  String get viewProfile => 'Profili Gör';

  @override
  String get reject => 'Reddet';

  @override
  String get approve => 'Onayla';

  @override
  String get noPostsOwn => 'Henüz hiç gönderiniz yok';

  @override
  String get shareFirstPost =>
      'Anasayfadaki + butonunu kullanarak\nilk gönderinizi paylaşabilirsiniz.';

  @override
  String get postingNgoOnly =>
      'Gönderi paylaşımı sadece STK hesapları için kullanılabilir.';

  @override
  String get editPost => 'Gönderiyi Düzenle';

  @override
  String get titleFieldLabel => 'Başlık';

  @override
  String get titleCannotBeEmpty => 'Başlık boş olamaz';

  @override
  String get descriptionLabel => 'Açıklama';

  @override
  String get deletePost => 'Gönderiyi Sil';

  @override
  String get deletePostConfirm =>
      'Bu gönderiyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get edit => 'Düzenle';

  @override
  String get levelObserver => 'Gözlemci';

  @override
  String get levelActive => 'Aktif';

  @override
  String get levelPioneer => 'Öncü';

  @override
  String get levelMaster => 'Usta';

  @override
  String get levelLegend => 'Efsane';
}
