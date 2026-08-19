import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'GönüllüNet'**
  String get appTitle;

  /// No description provided for @languageTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get languageEnglish;

  /// No description provided for @languageOption.
  ///
  /// In tr, this message translates to:
  /// **'Dil Seçeneği'**
  String get languageOption;

  /// No description provided for @selectLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil Seçin'**
  String get selectLanguage;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @yes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @comingSoon.
  ///
  /// In tr, this message translates to:
  /// **'{feature} yakında eklenecek!'**
  String comingSoon(String feature);

  /// No description provided for @errorOccurred.
  ///
  /// In tr, this message translates to:
  /// **'Hata oluştu: {error}'**
  String errorOccurred(String error);

  /// No description provided for @profileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @accountAndActions.
  ///
  /// In tr, this message translates to:
  /// **'Hesap & İşlemler'**
  String get accountAndActions;

  /// No description provided for @accountSettings.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Ayarları'**
  String get accountSettings;

  /// No description provided for @myPosts.
  ///
  /// In tr, this message translates to:
  /// **'Gönderilerim'**
  String get myPosts;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @events.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlikler'**
  String get events;

  /// No description provided for @myPublishedEvents.
  ///
  /// In tr, this message translates to:
  /// **'Yayınladığım Etkinlikler'**
  String get myPublishedEvents;

  /// No description provided for @myJoinedEvents.
  ///
  /// In tr, this message translates to:
  /// **'Katıldığım Etkinlikler'**
  String get myJoinedEvents;

  /// No description provided for @application.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama'**
  String get application;

  /// No description provided for @generalSettings.
  ///
  /// In tr, this message translates to:
  /// **'Genel Ayarlar'**
  String get generalSettings;

  /// No description provided for @about.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  /// No description provided for @signOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapmak istediğinizden emin misiniz?'**
  String get signOutConfirm;

  /// No description provided for @version.
  ///
  /// In tr, this message translates to:
  /// **'Versiyon {version}'**
  String version(String version);

  /// No description provided for @corporateMember.
  ///
  /// In tr, this message translates to:
  /// **'Kurumsal Üye'**
  String get corporateMember;

  /// No description provided for @volunteerMember.
  ///
  /// In tr, this message translates to:
  /// **'Gönüllü Üye'**
  String get volunteerMember;

  /// No description provided for @nextLevel.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki Seviye: {xp} XP'**
  String nextLevel(Object xp);

  /// No description provided for @xpInfo.
  ///
  /// In tr, this message translates to:
  /// **'Etkinliklere katılarak, paylaşım yaparak ve etkileşim kurarak XP kazanabilirsin.\nRozetler: Gözlemci (0+), Aktif (100+), Öncü (500+), Usta (1500+), Efsane (5000+)'**
  String get xpInfo;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @changePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Değiştir'**
  String get changePassword;

  /// No description provided for @notificationSettings.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Ayarları'**
  String get notificationSettings;

  /// No description provided for @accountSettingsSection.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Ayarları'**
  String get accountSettingsSection;

  /// No description provided for @deleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabımı Sil'**
  String get deleteAccount;

  /// No description provided for @privacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicy;

  /// No description provided for @aboutUs.
  ///
  /// In tr, this message translates to:
  /// **'Hakkımızda'**
  String get aboutUs;

  /// No description provided for @rateApp.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı Değerlendir'**
  String get rateApp;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızı silmek istediğinize emin misiniz?'**
  String get deleteAccountConfirm;

  /// No description provided for @cancelUpper.
  ///
  /// In tr, this message translates to:
  /// **'İPTAL'**
  String get cancelUpper;

  /// No description provided for @yesDelete.
  ///
  /// In tr, this message translates to:
  /// **'EVET, SİL'**
  String get yesDelete;

  /// No description provided for @onboardTitle1.
  ///
  /// In tr, this message translates to:
  /// **'GönüllüNet\'e\nHoş Geldin'**
  String get onboardTitle1;

  /// No description provided for @onboardDesc1.
  ///
  /// In tr, this message translates to:
  /// **'Çevrendeki iyilik hareketlerini keşfet, topluluğa katıl ve fark yaratmaya hemen başla.'**
  String get onboardDesc1;

  /// No description provided for @onboardTitle2.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlikleri\nKeşfet'**
  String get onboardTitle2;

  /// No description provided for @onboardDesc2.
  ///
  /// In tr, this message translates to:
  /// **'Sana en yakın gönüllülük etkinliklerini harita üzerinde bul ve ilgi alanına göre filtrele.'**
  String get onboardDesc2;

  /// No description provided for @onboardTitle3.
  ///
  /// In tr, this message translates to:
  /// **'Birlikte\nGüçlüyüz'**
  String get onboardTitle3;

  /// No description provided for @onboardDesc3.
  ///
  /// In tr, this message translates to:
  /// **'STK\'lar ve gönüllülerle bir araya gelerek büyük değişimlerin bir parçası ol.'**
  String get onboardDesc3;

  /// No description provided for @onboardSkip.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get onboardSkip;

  /// No description provided for @onboardStart.
  ///
  /// In tr, this message translates to:
  /// **'Keşfetmeye Başla'**
  String get onboardStart;

  /// No description provided for @onboardContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get onboardContinue;

  /// No description provided for @emailEmpty.
  ///
  /// In tr, this message translates to:
  /// **'E-posta boş bırakılamaz.'**
  String get emailEmpty;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz e-posta formatı.'**
  String get invalidEmailFormat;

  /// No description provided for @invalidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz e-posta adresi.'**
  String get invalidEmail;

  /// No description provided for @passwordEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Şifre boş bırakılamaz.'**
  String get passwordEmpty;

  /// No description provided for @passwordWeak.
  ///
  /// In tr, this message translates to:
  /// **'Şifre zayıf. En az 8 karakter, büyük/küçük harf, rakam ve özel karakter içermelidir.'**
  String get passwordWeak;

  /// No description provided for @nameEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Ad boş bırakılamaz.'**
  String get nameEmpty;

  /// No description provided for @surnameEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Soyad boş bırakılamaz.'**
  String get surnameEmpty;

  /// No description provided for @ngoNameEmpty.
  ///
  /// In tr, this message translates to:
  /// **'STK adı boş bırakılamaz.'**
  String get ngoNameEmpty;

  /// No description provided for @almostReady.
  ///
  /// In tr, this message translates to:
  /// **'Neredeyse Hazır!'**
  String get almostReady;

  /// No description provided for @selectUserType.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen kullanıcı türünüzü seçerek devam edin.'**
  String get selectUserType;

  /// No description provided for @roleVolunteer.
  ///
  /// In tr, this message translates to:
  /// **'Gönüllü'**
  String get roleVolunteer;

  /// No description provided for @roleVolunteerDesc.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik ara ve katıl'**
  String get roleVolunteerDesc;

  /// No description provided for @roleNgo.
  ///
  /// In tr, this message translates to:
  /// **'STK'**
  String get roleNgo;

  /// No description provided for @roleNgoDesc.
  ///
  /// In tr, this message translates to:
  /// **'Kurum profili oluştur'**
  String get roleNgoDesc;

  /// No description provided for @welcomeBack.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Hoş Geldin!'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İyilik yolculuğuna kaldığın yerden devam et.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In tr, this message translates to:
  /// **'merhaba@ornek.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get passwordLabel;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// No description provided for @noAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get signUp;

  /// No description provided for @signupVolunteerTagline.
  ///
  /// In tr, this message translates to:
  /// **'Gönüllü Ol, Etkinliklere Katıl'**
  String get signupVolunteerTagline;

  /// No description provided for @signupNgoTagline.
  ///
  /// In tr, this message translates to:
  /// **'Kurum Portalı'**
  String get signupNgoTagline;

  /// No description provided for @createAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Oluştur'**
  String get createAccount;

  /// No description provided for @signupVolunteerSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Gönüllü olmak için bilgilerinizi giriniz.'**
  String get signupVolunteerSubtitle;

  /// No description provided for @signupNgoSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Gönüllülerle buluşmak için katılın.'**
  String get signupNgoSubtitle;

  /// No description provided for @firstName.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In tr, this message translates to:
  /// **'Soyad'**
  String get lastName;

  /// No description provided for @emailAddress.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Adresi'**
  String get emailAddress;

  /// No description provided for @ngoName.
  ///
  /// In tr, this message translates to:
  /// **'STK Adı'**
  String get ngoName;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten bir hesabın var mı?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginAction.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get loginAction;

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get navHome;

  /// No description provided for @navDiscover.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get navDiscover;

  /// No description provided for @navOrganizations.
  ///
  /// In tr, this message translates to:
  /// **'Kurumlar'**
  String get navOrganizations;

  /// No description provided for @navMessages.
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar'**
  String get navMessages;

  /// No description provided for @navProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @assistant.
  ///
  /// In tr, this message translates to:
  /// **'Asistan'**
  String get assistant;

  /// No description provided for @homeGreeting.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba, 👋'**
  String get homeGreeting;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// No description provided for @noPostsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz hiç gönderi yok.\nSTK\'lar burada paylaşım yapacak.'**
  String get noPostsYet;

  /// No description provided for @ngoPostsSection.
  ///
  /// In tr, this message translates to:
  /// **'STK PAYLAŞIMLARI'**
  String get ngoPostsSection;

  /// No description provided for @upcomingEvents.
  ///
  /// In tr, this message translates to:
  /// **'YAKLAŞAN ETKİNLİKLER'**
  String get upcomingEvents;

  /// No description provided for @seeAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Gör'**
  String get seeAll;

  /// No description provided for @seeAllShort.
  ///
  /// In tr, this message translates to:
  /// **'Hepsini Gör'**
  String get seeAllShort;

  /// No description provided for @defaultVolunteerName.
  ///
  /// In tr, this message translates to:
  /// **'Gönüllü'**
  String get defaultVolunteerName;

  /// No description provided for @defaultNgoName.
  ///
  /// In tr, this message translates to:
  /// **'STK'**
  String get defaultNgoName;

  /// No description provided for @errorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bir Hata Oluştu'**
  String get errorTitle;

  /// No description provided for @checkingProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil Bilgileri Kontrol Ediliyor...'**
  String get checkingProfile;

  /// No description provided for @userSessionNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı oturumu bulunamadı.'**
  String get userSessionNotFound;

  /// No description provided for @verificationEmailResent.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama e-postası tekrar gönderildi.'**
  String get verificationEmailResent;

  /// No description provided for @tooManyRequests.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla istek gönderildi. Lütfen birkaç dakika bekleyin.'**
  String get tooManyRequests;

  /// No description provided for @emailSendFailed.
  ///
  /// In tr, this message translates to:
  /// **'E-posta gönderilemedi: {error}'**
  String emailSendFailed(String error);

  /// No description provided for @unexpectedError.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmeyen hata: {error}'**
  String unexpectedError(String error);

  /// No description provided for @verifyYourEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-postanızı Doğrulayın'**
  String get verifyYourEmail;

  /// No description provided for @cancelRegistrationTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt işlemini iptal et'**
  String get cancelRegistrationTooltip;

  /// No description provided for @verificationLinkSent.
  ///
  /// In tr, this message translates to:
  /// **'Bu adrese bir doğrulama bağlantısı gönderdik. Bağlantıya tıkladıktan sonra uygulama otomatik olarak devam edecek.'**
  String get verificationLinkSent;

  /// No description provided for @countdownExpired.
  ///
  /// In tr, this message translates to:
  /// **'doldu'**
  String get countdownExpired;

  /// No description provided for @countdownRemaining.
  ///
  /// In tr, this message translates to:
  /// **'kalan'**
  String get countdownRemaining;

  /// No description provided for @checkInbox.
  ///
  /// In tr, this message translates to:
  /// **'E-posta kutunuzu kontrol edin. Doğrulama bağlantısına tıkladıktan sonra otomatik olarak yönlendirileceksiniz.'**
  String get checkInbox;

  /// No description provided for @timeUp.
  ///
  /// In tr, this message translates to:
  /// **'Süre Doldu!'**
  String get timeUp;

  /// No description provided for @linkExpiredDesc.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama bağlantısının süresi geçti. Aşağıdaki butona basarak yeni bir bağlantı gönderebilirsiniz.'**
  String get linkExpiredDesc;

  /// No description provided for @sending.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiliyor...'**
  String get sending;

  /// No description provided for @sendNewLink.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Bağlantı Gönder'**
  String get sendNewLink;

  /// No description provided for @resendLink.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı Yeniden Gönder'**
  String get resendLink;

  /// No description provided for @resendIn.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden Gönder ({seconds} s)'**
  String resendIn(Object seconds);

  /// No description provided for @cancelReturnLogin.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç — Giriş ekranına dön'**
  String get cancelReturnLogin;

  /// No description provided for @allEvents.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Etkinlikler'**
  String get allEvents;

  /// No description provided for @noEventsFound.
  ///
  /// In tr, this message translates to:
  /// **'Henüz hiç etkinlik yok\nveya filtreye uygun sonuç bulunamadı.'**
  String get noEventsFound;

  /// No description provided for @clearFilters.
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri Temizle'**
  String get clearFilters;

  /// No description provided for @eventsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Gönüllü etkinlikleri keşfet ve katıl'**
  String get eventsSubtitle;

  /// No description provided for @filter.
  ///
  /// In tr, this message translates to:
  /// **'Filtre'**
  String get filter;

  /// No description provided for @fullScreen.
  ///
  /// In tr, this message translates to:
  /// **'Tam Ekran'**
  String get fullScreen;

  /// No description provided for @statUpcoming.
  ///
  /// In tr, this message translates to:
  /// **'{count} Yaklaşan'**
  String statUpcoming(Object count);

  /// No description provided for @statOnMap.
  ///
  /// In tr, this message translates to:
  /// **'{count} Haritada'**
  String statOnMap(Object count);

  /// No description provided for @imagePickFailed.
  ///
  /// In tr, this message translates to:
  /// **'Resim seçilemedi: {error}'**
  String imagePickFailed(String error);

  /// No description provided for @titleEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Başlık boş bırakılamaz.'**
  String get titleEmpty;

  /// No description provided for @selectLocationOnMap.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen haritadan bir konum seçin.'**
  String get selectLocationOnMap;

  /// No description provided for @selectAllTimes.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen başlangıç, bitiş ve son başvuru zamanlarını seçin.'**
  String get selectAllTimes;

  /// No description provided for @endBeforeStart.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş tarihi başlangıçtan önce olamaz!'**
  String get endBeforeStart;

  /// No description provided for @lastApplyAfterStart.
  ///
  /// In tr, this message translates to:
  /// **'Son başvuru tarihi başlangıç tarihinden sonra olamaz!'**
  String get lastApplyAfterStart;

  /// No description provided for @lastApplyInPast.
  ///
  /// In tr, this message translates to:
  /// **'Son başvuru tarihi geçmiş bir zaman olamaz!'**
  String get lastApplyInPast;

  /// No description provided for @selectPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Seçiniz'**
  String get selectPlaceholder;

  /// No description provided for @eventCreatedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'İçerik başarıyla oluşturuldu!'**
  String get eventCreatedSuccess;

  /// No description provided for @newEvent.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Etkinlik'**
  String get newEvent;

  /// No description provided for @publish.
  ///
  /// In tr, this message translates to:
  /// **'Yayınla'**
  String get publish;

  /// No description provided for @eventTitleHint.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik Başlığı'**
  String get eventTitleHint;

  /// No description provided for @eventDescriptionHint.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik hakkında bilgi ver...'**
  String get eventDescriptionHint;

  /// No description provided for @type.
  ///
  /// In tr, this message translates to:
  /// **'Tür'**
  String get type;

  /// No description provided for @category.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get category;

  /// No description provided for @quotaOptional.
  ///
  /// In tr, this message translates to:
  /// **'Kontenjan (Opsiyonel)'**
  String get quotaOptional;

  /// No description provided for @location.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get location;

  /// No description provided for @change.
  ///
  /// In tr, this message translates to:
  /// **'Değiştir'**
  String get change;

  /// No description provided for @selectLocationFromMap.
  ///
  /// In tr, this message translates to:
  /// **'Haritadan Konum Seç'**
  String get selectLocationFromMap;

  /// No description provided for @startLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get startLabel;

  /// No description provided for @endLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş'**
  String get endLabel;

  /// No description provided for @lastApplyDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Son Başvuru Tarihi'**
  String get lastApplyDateLabel;

  /// No description provided for @addImageOptional.
  ///
  /// In tr, this message translates to:
  /// **'Görsel Ekle (Opsiyonel)'**
  String get addImageOptional;

  /// No description provided for @categoryAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get categoryAll;

  /// No description provided for @categoryGeneral.
  ///
  /// In tr, this message translates to:
  /// **'Genel'**
  String get categoryGeneral;

  /// No description provided for @categoryEducation.
  ///
  /// In tr, this message translates to:
  /// **'Eğitim'**
  String get categoryEducation;

  /// No description provided for @categoryEnvironment.
  ///
  /// In tr, this message translates to:
  /// **'Çevre'**
  String get categoryEnvironment;

  /// No description provided for @categoryHealth.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık'**
  String get categoryHealth;

  /// No description provided for @categoryAnimalRights.
  ///
  /// In tr, this message translates to:
  /// **'Hayvan Hakları'**
  String get categoryAnimalRights;

  /// No description provided for @categoryDisaster.
  ///
  /// In tr, this message translates to:
  /// **'Afet'**
  String get categoryDisaster;

  /// No description provided for @categoryArt.
  ///
  /// In tr, this message translates to:
  /// **'Sanat'**
  String get categoryArt;

  /// No description provided for @categorySports.
  ///
  /// In tr, this message translates to:
  /// **'Spor'**
  String get categorySports;

  /// No description provided for @categoryCulture.
  ///
  /// In tr, this message translates to:
  /// **'Kültür'**
  String get categoryCulture;

  /// No description provided for @typeEvent.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik'**
  String get typeEvent;

  /// No description provided for @typeProject.
  ///
  /// In tr, this message translates to:
  /// **'Proje'**
  String get typeProject;

  /// No description provided for @eventFull.
  ///
  /// In tr, this message translates to:
  /// **'Dolu'**
  String get eventFull;

  /// No description provided for @beFirstToJoin.
  ///
  /// In tr, this message translates to:
  /// **'İlk sen ol!'**
  String get beFirstToJoin;

  /// No description provided for @filterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele'**
  String get filterTitle;

  /// No description provided for @clear.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get clear;

  /// No description provided for @cityLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şehir'**
  String get cityLabel;

  /// No description provided for @eventCategoryLabel.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik Türü'**
  String get eventCategoryLabel;

  /// No description provided for @selectDateRange.
  ///
  /// In tr, this message translates to:
  /// **'Tarih Aralığı Seç'**
  String get selectDateRange;

  /// No description provided for @apply.
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get apply;

  /// No description provided for @organizer.
  ///
  /// In tr, this message translates to:
  /// **'Düzenleyen'**
  String get organizer;

  /// No description provided for @loading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get loading;

  /// No description provided for @applicationStat.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru'**
  String get applicationStat;

  /// No description provided for @participantStat.
  ///
  /// In tr, this message translates to:
  /// **'Katılımcı'**
  String get participantStat;

  /// No description provided for @personCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Kişi'**
  String personCount(Object count);

  /// No description provided for @soFar.
  ///
  /// In tr, this message translates to:
  /// **'Şimdiye kadar'**
  String get soFar;

  /// No description provided for @manageApplications.
  ///
  /// In tr, this message translates to:
  /// **'Başvuruları Yönet'**
  String get manageApplications;

  /// No description provided for @eventExpired.
  ///
  /// In tr, this message translates to:
  /// **'Bu etkinliğin süresi doldu'**
  String get eventExpired;

  /// No description provided for @applicationClosed.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru süresi doldu'**
  String get applicationClosed;

  /// No description provided for @applyNow.
  ///
  /// In tr, this message translates to:
  /// **'Hemen Başvur'**
  String get applyNow;

  /// No description provided for @leaveEvent.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlikten Ayrıl'**
  String get leaveEvent;

  /// No description provided for @applicationPending.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru Bekleniyor (İptal)'**
  String get applicationPending;

  /// No description provided for @leaveEventConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlikten ayrılmak istediğinize emin misiniz?'**
  String get leaveEventConfirm;

  /// No description provided for @cancelApplicationConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Başvurunuzu iptal etmek istediğinize emin misiniz?'**
  String get cancelApplicationConfirm;

  /// No description provided for @applicationSubmitted.
  ///
  /// In tr, this message translates to:
  /// **'Başvurunuz iletildi, onay bekleniyor!'**
  String get applicationSubmitted;

  /// No description provided for @projectLetterPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Bu projeye başvurmak için lütfen niyetinizi belirten bir mektup yazın. Başvurunuzun onaylanması için bu mektup kurum tarafından incelenecektir.'**
  String get projectLetterPrompt;

  /// No description provided for @letterHint.
  ///
  /// In tr, this message translates to:
  /// **'Niyetinizi bu alana detaylıca yazınız...'**
  String get letterHint;

  /// No description provided for @send.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;

  /// No description provided for @dateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get dateLabel;

  /// No description provided for @details.
  ///
  /// In tr, this message translates to:
  /// **'Detaylar'**
  String get details;

  /// No description provided for @quotaFull.
  ///
  /// In tr, this message translates to:
  /// **'Kontenjan Dolu'**
  String get quotaFull;

  /// No description provided for @intentLetter.
  ///
  /// In tr, this message translates to:
  /// **'Niyet Mektubu'**
  String get intentLetter;

  /// No description provided for @charCountLabel.
  ///
  /// In tr, this message translates to:
  /// **'{count} / {min} karakter'**
  String charCountLabel(Object count, Object min);

  /// No description provided for @lastApplyPrefix.
  ///
  /// In tr, this message translates to:
  /// **'Son Başvuru: {date}'**
  String lastApplyPrefix(String date);

  /// No description provided for @searchEvent.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik ara...'**
  String get searchEvent;

  /// No description provided for @shrink.
  ///
  /// In tr, this message translates to:
  /// **'Küçült'**
  String get shrink;

  /// No description provided for @noEventsForCriteria.
  ///
  /// In tr, this message translates to:
  /// **'Bu kritere uygun etkinlik bulunamadı.'**
  String get noEventsForCriteria;

  /// No description provided for @examine.
  ///
  /// In tr, this message translates to:
  /// **'İncele'**
  String get examine;

  /// No description provided for @participantCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} katılımcı'**
  String participantCount(Object count);

  /// No description provided for @userNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı bulunamadı'**
  String get userNotFound;

  /// No description provided for @noEventsPublished.
  ///
  /// In tr, this message translates to:
  /// **'Henüz etkinlik yayınlamadınız.'**
  String get noEventsPublished;

  /// No description provided for @noEventsJoined.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir etkinliğe katılmadınız.'**
  String get noEventsJoined;

  /// No description provided for @searchLocationHint.
  ///
  /// In tr, this message translates to:
  /// **'Konum ara...'**
  String get searchLocationHint;

  /// No description provided for @selectingLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum seçiliyor...'**
  String get selectingLocation;

  /// No description provided for @selectedAddress.
  ///
  /// In tr, this message translates to:
  /// **'Seçilen Adres'**
  String get selectedAddress;

  /// No description provided for @addressFinding.
  ///
  /// In tr, this message translates to:
  /// **'Adres bulunuyor...'**
  String get addressFinding;

  /// No description provided for @confirmLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konumu Onayla'**
  String get confirmLocation;

  /// No description provided for @likeCountLabel.
  ///
  /// In tr, this message translates to:
  /// **'{count} Beğeni'**
  String likeCountLabel(Object count);

  /// No description provided for @commentCountLabel.
  ///
  /// In tr, this message translates to:
  /// **'{count} Yorum'**
  String commentCountLabel(Object count);

  /// No description provided for @like.
  ///
  /// In tr, this message translates to:
  /// **'Beğen'**
  String get like;

  /// No description provided for @comment.
  ///
  /// In tr, this message translates to:
  /// **'Yorum'**
  String get comment;

  /// No description provided for @descriptionEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama boş bırakılamaz.'**
  String get descriptionEmpty;

  /// No description provided for @checkAllBoxes.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tüm onay kutucuklarını işaretleyin.'**
  String get checkAllBoxes;

  /// No description provided for @imageUploadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Resim yüklenemedi, URL boş döndü.'**
  String get imageUploadFailed;

  /// No description provided for @postShared.
  ///
  /// In tr, this message translates to:
  /// **'Gönderi başarıyla paylaşıldı.'**
  String get postShared;

  /// No description provided for @newPost.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Gönderi'**
  String get newPost;

  /// No description provided for @share.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get share;

  /// No description provided for @addTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başlık Ekle'**
  String get addTitle;

  /// No description provided for @whatsHappening.
  ///
  /// In tr, this message translates to:
  /// **'Neler oluyor?'**
  String get whatsHappening;

  /// No description provided for @addPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Ekle'**
  String get addPhoto;

  /// No description provided for @consentAccuracy.
  ///
  /// In tr, this message translates to:
  /// **'Paylaştığım içeriğin doğruluğundan sorumluyum.'**
  String get consentAccuracy;

  /// No description provided for @consentRules.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk kurallarına uygun hareket edeceğimi taahhüt ederim.'**
  String get consentRules;

  /// No description provided for @noComments.
  ///
  /// In tr, this message translates to:
  /// **'Henüz yorum yok. İlk yorumu sen yap!'**
  String get noComments;

  /// No description provided for @commentHint.
  ///
  /// In tr, this message translates to:
  /// **'Yorumunuzu yazın...'**
  String get commentHint;

  /// No description provided for @filterByCity.
  ///
  /// In tr, this message translates to:
  /// **'Şehre Göre Filtrele'**
  String get filterByCity;

  /// No description provided for @searchCity.
  ///
  /// In tr, this message translates to:
  /// **'Şehir ara...'**
  String get searchCity;

  /// No description provided for @noCityInfo.
  ///
  /// In tr, this message translates to:
  /// **'Henüz şehir bilgisi mevcut değil.'**
  String get noCityInfo;

  /// No description provided for @noCityMatch.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşen şehir bulunamadı.'**
  String get noCityMatch;

  /// No description provided for @allOrganizations.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Kurumlar'**
  String get allOrganizations;

  /// No description provided for @ngosSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sivil toplum kuruluşlarını keşfet ve destek ol'**
  String get ngosSubtitle;

  /// No description provided for @noResults.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı.'**
  String get noResults;

  /// No description provided for @ngoDetail.
  ///
  /// In tr, this message translates to:
  /// **'STK Detayı'**
  String get ngoDetail;

  /// No description provided for @civilSocietyOrg.
  ///
  /// In tr, this message translates to:
  /// **'Sivil Toplum Kuruluşu'**
  String get civilSocietyOrg;

  /// No description provided for @unfollow.
  ///
  /// In tr, this message translates to:
  /// **'Takibi Bırak'**
  String get unfollow;

  /// No description provided for @follow.
  ///
  /// In tr, this message translates to:
  /// **'Takip Et'**
  String get follow;

  /// No description provided for @contact.
  ///
  /// In tr, this message translates to:
  /// **'İletişim'**
  String get contact;

  /// No description provided for @followers.
  ///
  /// In tr, this message translates to:
  /// **'Takipçi'**
  String get followers;

  /// No description provided for @tabDescription.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get tabDescription;

  /// No description provided for @tabPosts.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiler'**
  String get tabPosts;

  /// No description provided for @contactInfo.
  ///
  /// In tr, this message translates to:
  /// **'İletişim Bilgileri'**
  String get contactInfo;

  /// No description provided for @noEventsShort.
  ///
  /// In tr, this message translates to:
  /// **'Henüz etkinlik yok.'**
  String get noEventsShort;

  /// No description provided for @noPostsShared.
  ///
  /// In tr, this message translates to:
  /// **'Henüz paylaşım yapılmamış.'**
  String get noPostsShared;

  /// No description provided for @locationUnspecified.
  ///
  /// In tr, this message translates to:
  /// **'Lokasyon Belirtilmemiş'**
  String get locationUnspecified;

  /// No description provided for @statEvent.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik'**
  String get statEvent;

  /// No description provided for @statScore.
  ///
  /// In tr, this message translates to:
  /// **'Puan'**
  String get statScore;

  /// No description provided for @ourMission.
  ///
  /// In tr, this message translates to:
  /// **'Misyonumuz'**
  String get ourMission;

  /// No description provided for @ourVision.
  ///
  /// In tr, this message translates to:
  /// **'Vizyonumuz'**
  String get ourVision;

  /// No description provided for @groupChatsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Katıldığın etkinliklerin grup sohbetleri'**
  String get groupChatsSubtitle;

  /// No description provided for @connectionError.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı Hatası'**
  String get connectionError;

  /// No description provided for @noActiveChats.
  ///
  /// In tr, this message translates to:
  /// **'Henüz aktif sohbet yok'**
  String get noActiveChats;

  /// No description provided for @joinEventsForChats.
  ///
  /// In tr, this message translates to:
  /// **'Etkinliklere katılarak\ngrup sohbetlerine dahil ol!'**
  String get joinEventsForChats;

  /// No description provided for @discoverEvents.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlikleri Keşfet'**
  String get discoverEvents;

  /// No description provided for @userInfoUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı bilgisi alınamadı.'**
  String get userInfoUnavailable;

  /// No description provided for @genericErrorMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu:\n{message}'**
  String genericErrorMessage(String message);

  /// No description provided for @deleteAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Sil'**
  String get deleteAll;

  /// No description provided for @noNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bildiriminiz yok.'**
  String get noNotifications;

  /// No description provided for @deleteAllConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Tüm bildirimleri silmek istediğinize emin misiniz?'**
  String get deleteAllConfirm;

  /// No description provided for @allNotificationsDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Tüm bildirimler silindi'**
  String get allNotificationsDeleted;

  /// No description provided for @volunteerAi.
  ///
  /// In tr, this message translates to:
  /// **'Gönüllü AI'**
  String get volunteerAi;

  /// No description provided for @smartAssistant.
  ///
  /// In tr, this message translates to:
  /// **'Akıllı Asistan'**
  String get smartAssistant;

  /// No description provided for @aiGreeting.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba! 👋'**
  String get aiGreeting;

  /// No description provided for @aiIntro.
  ///
  /// In tr, this message translates to:
  /// **'Ben GönüllüNet AI Asistanı.\nErasmus+, gönüllülük projeleri ve STK\'lar\nhakkında sorularınızı yanıtlayabilirim.'**
  String get aiIntro;

  /// No description provided for @quickStart.
  ///
  /// In tr, this message translates to:
  /// **'HIZLI BAŞLANGIÇ'**
  String get quickStart;

  /// No description provided for @qErasmus.
  ///
  /// In tr, this message translates to:
  /// **'Erasmus+ nedir?'**
  String get qErasmus;

  /// No description provided for @qHowVolunteer.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl gönüllü olabilirim?'**
  String get qHowVolunteer;

  /// No description provided for @qHowJoinNgo.
  ///
  /// In tr, this message translates to:
  /// **'STK\'lara nasıl katılırım?'**
  String get qHowJoinNgo;

  /// No description provided for @qNearbyEvents.
  ///
  /// In tr, this message translates to:
  /// **'Bana yakın etkinlikler'**
  String get qNearbyEvents;

  /// No description provided for @qNearbyEventsFull.
  ///
  /// In tr, this message translates to:
  /// **'Bana yakın gönüllülük etkinlikleri nelerdir?'**
  String get qNearbyEventsFull;

  /// No description provided for @deleteChat.
  ///
  /// In tr, this message translates to:
  /// **'Sohbeti Sil'**
  String get deleteChat;

  /// No description provided for @deleteChatConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu sohbet kalıcı olarak silinecek. Emin misiniz?'**
  String get deleteChatConfirm;

  /// No description provided for @smartVolunteerAssistant.
  ///
  /// In tr, this message translates to:
  /// **'Akıllı Gönüllülük Asistanı'**
  String get smartVolunteerAssistant;

  /// No description provided for @pastChats.
  ///
  /// In tr, this message translates to:
  /// **'GEÇMİŞ SOHBETLER'**
  String get pastChats;

  /// No description provided for @aiAssistantTitle.
  ///
  /// In tr, this message translates to:
  /// **'GönüllüNet AI Asistanı'**
  String get aiAssistantTitle;

  /// No description provided for @aiHistoryIntro.
  ///
  /// In tr, this message translates to:
  /// **'Erasmus+, gönüllülük projeleri, STK\'lar ve\nsosyal sorumluluk hakkında bilgi almak için\nyeni bir sohbet başlatın.'**
  String get aiHistoryIntro;

  /// No description provided for @startNewChat.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Sohbet Başlat'**
  String get startNewChat;

  /// No description provided for @askNewQuestion.
  ///
  /// In tr, this message translates to:
  /// **'AI asistanına yeni bir soru sor'**
  String get askNewQuestion;

  /// No description provided for @messageHint.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj yazın...'**
  String get messageHint;

  /// No description provided for @noMessages.
  ///
  /// In tr, this message translates to:
  /// **'Henüz hiç mesaj yok.\nİlk mesajı sen gönder!'**
  String get noMessages;

  /// No description provided for @editProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profilini Düzenle'**
  String get editProfile;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Profil başarıyla güncellendi!'**
  String get profileUpdatedSuccess;

  /// No description provided for @profileUpdating.
  ///
  /// In tr, this message translates to:
  /// **'Profil güncelleniyor...'**
  String get profileUpdating;

  /// No description provided for @profileVisibilityNote.
  ///
  /// In tr, this message translates to:
  /// **'Profil bilgileriniz başvuru yapacağınız etkinliğin sahibi STK tarafından görüntülenecektir.'**
  String get profileVisibilityNote;

  /// No description provided for @aboutMe.
  ///
  /// In tr, this message translates to:
  /// **'Hakkımda'**
  String get aboutMe;

  /// No description provided for @aboutMeHint.
  ///
  /// In tr, this message translates to:
  /// **'Kendinizi tanıtın, motivasyonunuzu ve neden gönüllülük yaptığınızı yazın...'**
  String get aboutMeHint;

  /// No description provided for @interests.
  ///
  /// In tr, this message translates to:
  /// **'İlgi Alanları'**
  String get interests;

  /// No description provided for @skills.
  ///
  /// In tr, this message translates to:
  /// **'Yetenekler'**
  String get skills;

  /// No description provided for @birthDate.
  ///
  /// In tr, this message translates to:
  /// **'Doğum Tarihi'**
  String get birthDate;

  /// No description provided for @selectBirthDate.
  ///
  /// In tr, this message translates to:
  /// **'Doğum tarihinizi seçin'**
  String get selectBirthDate;

  /// No description provided for @educationProfession.
  ///
  /// In tr, this message translates to:
  /// **'Eğitim Durumu / Meslek'**
  String get educationProfession;

  /// No description provided for @educationHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Üniversite Öğrencisi, Psikoloji Bölümü'**
  String get educationHint;

  /// No description provided for @locationCityDistrict.
  ///
  /// In tr, this message translates to:
  /// **'Konum (Şehir / İlçe)'**
  String get locationCityDistrict;

  /// No description provided for @locationExampleHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Kadıköy, İstanbul'**
  String get locationExampleHint;

  /// No description provided for @phoneNumber.
  ///
  /// In tr, this message translates to:
  /// **'Telefon Numarası'**
  String get phoneNumber;

  /// No description provided for @ngoNameEmptyError.
  ///
  /// In tr, this message translates to:
  /// **'STK Adı boş olamaz.'**
  String get ngoNameEmptyError;

  /// No description provided for @editNgoProfile.
  ///
  /// In tr, this message translates to:
  /// **'STK Profilini Düzenle'**
  String get editNgoProfile;

  /// No description provided for @tapToChangeLogo.
  ///
  /// In tr, this message translates to:
  /// **'Logoyu değiştirmek için dokunun'**
  String get tapToChangeLogo;

  /// No description provided for @cityExampleHint.
  ///
  /// In tr, this message translates to:
  /// **'Kadıköy, İstanbul'**
  String get cityExampleHint;

  /// No description provided for @ngoDescriptionHint.
  ///
  /// In tr, this message translates to:
  /// **'Kuruluşunuz hakkında kısa bir açıklama yazın...'**
  String get ngoDescriptionHint;

  /// No description provided for @visionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Vizyon'**
  String get visionLabel;

  /// No description provided for @missionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Misyon'**
  String get missionLabel;

  /// No description provided for @visionHint.
  ///
  /// In tr, this message translates to:
  /// **'Vizyonunuz...'**
  String get visionHint;

  /// No description provided for @missionHint.
  ///
  /// In tr, this message translates to:
  /// **'Misyonunuz...'**
  String get missionHint;

  /// No description provided for @locationEmptyError.
  ///
  /// In tr, this message translates to:
  /// **'Konum boş olamaz.'**
  String get locationEmptyError;

  /// No description provided for @phoneEmptyError.
  ///
  /// In tr, this message translates to:
  /// **'Telefon boş olamaz.'**
  String get phoneEmptyError;

  /// No description provided for @visionEmptyError.
  ///
  /// In tr, this message translates to:
  /// **'Vizyon boş olamaz.'**
  String get visionEmptyError;

  /// No description provided for @missionEmptyError.
  ///
  /// In tr, this message translates to:
  /// **'Misyon boş olamaz.'**
  String get missionEmptyError;

  /// No description provided for @socialMediaLinks.
  ///
  /// In tr, this message translates to:
  /// **'Sosyal Medya Bağlantıları'**
  String get socialMediaLinks;

  /// No description provided for @facebookLabel.
  ///
  /// In tr, this message translates to:
  /// **'Facebook (Opsiyonel)'**
  String get facebookLabel;

  /// No description provided for @facebookHint.
  ///
  /// In tr, this message translates to:
  /// **'https://facebook.com/sayfaniz'**
  String get facebookHint;

  /// No description provided for @instagramLabel.
  ///
  /// In tr, this message translates to:
  /// **'Instagram (Opsiyonel)'**
  String get instagramLabel;

  /// No description provided for @instagramHint.
  ///
  /// In tr, this message translates to:
  /// **'https://instagram.com/hesabiniz'**
  String get instagramHint;

  /// No description provided for @twitterLabel.
  ///
  /// In tr, this message translates to:
  /// **'Twitter / X (Opsiyonel)'**
  String get twitterLabel;

  /// No description provided for @twitterHint.
  ///
  /// In tr, this message translates to:
  /// **'https://x.com/hesabiniz'**
  String get twitterHint;

  /// No description provided for @linkedinLabel.
  ///
  /// In tr, this message translates to:
  /// **'LinkedIn (Opsiyonel)'**
  String get linkedinLabel;

  /// No description provided for @linkedinHint.
  ///
  /// In tr, this message translates to:
  /// **'https://linkedin.com/company/kuruluşunuz'**
  String get linkedinHint;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı açılamadı.'**
  String get couldNotOpenLink;

  /// No description provided for @completeNgoProfileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profilinizi Tamamlayın'**
  String get completeNgoProfileTitle;

  /// No description provided for @completeNgoProfileNotice.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı kullanmaya başlamadan önce STK profilinizi tamamlamanız gerekiyor. Devam etmek için aşağıdaki tüm bilgileri doldurup kaydedin.'**
  String get completeNgoProfileNotice;

  /// No description provided for @applicantProfile.
  ///
  /// In tr, this message translates to:
  /// **'Başvuran Profili'**
  String get applicantProfile;

  /// No description provided for @applicationLetter.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru Niyet Mektubu'**
  String get applicationLetter;

  /// No description provided for @notSpecified.
  ///
  /// In tr, this message translates to:
  /// **'Belirtilmemiş'**
  String get notSpecified;

  /// No description provided for @ageLabel.
  ///
  /// In tr, this message translates to:
  /// **'{age} yaş'**
  String ageLabel(Object age);

  /// No description provided for @errNetwork.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantınızı kontrol edin.'**
  String get errNetwork;

  /// No description provided for @errTimeout.
  ///
  /// In tr, this message translates to:
  /// **'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.'**
  String get errTimeout;

  /// No description provided for @errUnexpected.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmedik bir hata oluştu. Lütfen tekrar deneyin.'**
  String get errUnexpected;

  /// No description provided for @errUnexpectedRetry.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.'**
  String get errUnexpectedRetry;

  /// No description provided for @errEmailInUse.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta adresi zaten kullanılıyor.'**
  String get errEmailInUse;

  /// No description provided for @errInvalidEmailAddr.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz e-posta adresi.'**
  String get errInvalidEmailAddr;

  /// No description provided for @errWeakPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 6 karakter olmalıdır.'**
  String get errWeakPassword;

  /// No description provided for @errWrongCredentials.
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya şifre hatalı.'**
  String get errWrongCredentials;

  /// No description provided for @errUserNotFoundAuth.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta adresine kayıtlı bir hesap bulunamadı.'**
  String get errUserNotFoundAuth;

  /// No description provided for @errUserDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Bu hesap devre dışı bırakılmış. Destek ile iletişime geçin.'**
  String get errUserDisabled;

  /// No description provided for @errTooManyAttempts.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla başarısız deneme. Lütfen bir süre bekleyin.'**
  String get errTooManyAttempts;

  /// No description provided for @errRequiresRecentLogin.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem için tekrar giriş yapmanız gerekiyor.'**
  String get errRequiresRecentLogin;

  /// No description provided for @errOperationNotAllowed.
  ///
  /// In tr, this message translates to:
  /// **'Bu giriş yöntemi şu an desteklenmiyor.'**
  String get errOperationNotAllowed;

  /// No description provided for @errExpiredActionCode.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantının süresi dolmuş. Lütfen yeni bir bağlantı isteyin.'**
  String get errExpiredActionCode;

  /// No description provided for @errInvalidActionCode.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz doğrulama bağlantısı.'**
  String get errInvalidActionCode;

  /// No description provided for @errAuthGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Kimlik doğrulama hatası. Lütfen tekrar deneyin.'**
  String get errAuthGeneric;

  /// No description provided for @errPermissionDenied.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem için yetkiniz bulunmuyor.'**
  String get errPermissionDenied;

  /// No description provided for @errNotFound.
  ///
  /// In tr, this message translates to:
  /// **'İstenen veri bulunamadı.'**
  String get errNotFound;

  /// No description provided for @errAlreadyExists.
  ///
  /// In tr, this message translates to:
  /// **'Bu kayıt zaten mevcut.'**
  String get errAlreadyExists;

  /// No description provided for @errResourceExhausted.
  ///
  /// In tr, this message translates to:
  /// **'Limitinize ulaştınız veya sunucu şu an çok yoğun.'**
  String get errResourceExhausted;

  /// No description provided for @errCancelled.
  ///
  /// In tr, this message translates to:
  /// **'İşlem iptal edildi.'**
  String get errCancelled;

  /// No description provided for @errUnauthenticated.
  ///
  /// In tr, this message translates to:
  /// **'Oturum süreniz doldu. Lütfen tekrar giriş yapın.'**
  String get errUnauthenticated;

  /// No description provided for @errFileNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Dosya bulunamadı.'**
  String get errFileNotFound;

  /// No description provided for @errQuotaExceeded.
  ///
  /// In tr, this message translates to:
  /// **'Depolama kotası aşıldı.'**
  String get errQuotaExceeded;

  /// No description provided for @errServer.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu hatası oluştu. Lütfen tekrar deneyin.'**
  String get errServer;

  /// No description provided for @errChatHistoryLoad.
  ///
  /// In tr, this message translates to:
  /// **'Sohbet geçmişi yüklenemedi.'**
  String get errChatHistoryLoad;

  /// No description provided for @errChatDelete.
  ///
  /// In tr, this message translates to:
  /// **'Sohbet silinemedi.'**
  String get errChatDelete;

  /// No description provided for @errMessagesLoad.
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar yüklenemedi.'**
  String get errMessagesLoad;

  /// No description provided for @errLocationFailed.
  ///
  /// In tr, this message translates to:
  /// **'Konum alınamadı.'**
  String get errLocationFailed;

  /// No description provided for @errLocationNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Konum bulunamadı.'**
  String get errLocationNotFound;

  /// No description provided for @errSearchFailed.
  ///
  /// In tr, this message translates to:
  /// **'Arama sırasında hata oluştu.'**
  String get errSearchFailed;

  /// No description provided for @errAddressDetail.
  ///
  /// In tr, this message translates to:
  /// **'Adres detayı alınamadı'**
  String get errAddressDetail;

  /// No description provided for @errUnknownLocation.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen Konum'**
  String get errUnknownLocation;

  /// No description provided for @errNotificationsLoad.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler alınamadı.'**
  String get errNotificationsLoad;

  /// No description provided for @errUserDataNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı verisi bulunamadı.'**
  String get errUserDataNotFound;

  /// No description provided for @errFollowFailed.
  ///
  /// In tr, this message translates to:
  /// **'Takip işlemi başarısız.'**
  String get errFollowFailed;

  /// No description provided for @errSignupFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt sırasında bir hata oluştu.'**
  String get errSignupFailed;

  /// No description provided for @errEventNgoOnly.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik oluşturmak için STK hesabınız olmalıdır.'**
  String get errEventNgoOnly;

  /// No description provided for @errEventLoginRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlemi yapmak için giriş yapmanız gerekiyor.'**
  String get errEventLoginRequired;

  /// No description provided for @errEventFillAll.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tüm alanları doldurun.'**
  String get errEventFillAll;

  /// No description provided for @errEventProfileNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı profili bulunamadı.'**
  String get errEventProfileNotFound;

  /// No description provided for @errEventCreateFailed.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik oluşturulamadı. Lütfen tekrar deneyin.'**
  String get errEventCreateFailed;

  /// No description provided for @errMessageSend.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj gönderilirken bir hata oluştu.'**
  String get errMessageSend;

  /// No description provided for @errAiDailyLimit.
  ///
  /// In tr, this message translates to:
  /// **'Bugünlük soru limitine ulaştın. Yarın tekrar görüşmek üzere! 🚀'**
  String get errAiDailyLimit;

  /// No description provided for @errAiBusy.
  ///
  /// In tr, this message translates to:
  /// **'Şu an çok yoğunum, lütfen bir dakika sonra tekrar dener misin? ☕'**
  String get errAiBusy;

  /// No description provided for @errAiTimeout.
  ///
  /// In tr, this message translates to:
  /// **'Yanıt vermem biraz uzun sürdü, internetini kontrol edip tekrar dener misin? ⏳'**
  String get errAiTimeout;

  /// No description provided for @errAiUnreachable.
  ///
  /// In tr, this message translates to:
  /// **'Sunucuya şu an ulaşılamıyor, lütfen daha sonra tekrar dene. 🛠️'**
  String get errAiUnreachable;

  /// No description provided for @errAiOpTimeout.
  ///
  /// In tr, this message translates to:
  /// **'İşlem zaman aşımına uğradı, lütfen tekrar dene. ⏳'**
  String get errAiOpTimeout;

  /// No description provided for @errImageUpload.
  ///
  /// In tr, this message translates to:
  /// **'Resim yükleme hatası.'**
  String get errImageUpload;

  /// No description provided for @errSessionNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı oturumu bulunamadı.'**
  String get errSessionNotFound;

  /// No description provided for @aboutAppName.
  ///
  /// In tr, this message translates to:
  /// **'GönüllüNet'**
  String get aboutAppName;

  /// No description provided for @aboutTagline.
  ///
  /// In tr, this message translates to:
  /// **'Birlikte iyilik için'**
  String get aboutTagline;

  /// No description provided for @aboutDescription.
  ///
  /// In tr, this message translates to:
  /// **'GönüllüNet; gönüllüleri ve sivil toplum kuruluşlarını bir araya getiren bir gönüllülük platformudur. Çevrendeki etkinlikleri keşfet, başvur, grup sohbetlerine katıl ve toplulukla birlikte fark yarat.'**
  String get aboutDescription;

  /// No description provided for @aboutContact.
  ///
  /// In tr, this message translates to:
  /// **'İletişim'**
  String get aboutContact;

  /// No description provided for @aboutContactEmail.
  ///
  /// In tr, this message translates to:
  /// **'gonullunet@gmail.com'**
  String get aboutContactEmail;

  /// No description provided for @aboutRights.
  ///
  /// In tr, this message translates to:
  /// **'© 2025 GönüllüNet. Tüm hakları saklıdır.'**
  String get aboutRights;

  /// No description provided for @aboutMadeWith.
  ///
  /// In tr, this message translates to:
  /// **'Sevgiyle geliştirildi ❤️'**
  String get aboutMadeWith;

  /// No description provided for @notifPushTitle.
  ///
  /// In tr, this message translates to:
  /// **'Anlık Bildirimler'**
  String get notifPushTitle;

  /// No description provided for @notifPushSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm bildirimleri aç veya kapat'**
  String get notifPushSubtitle;

  /// No description provided for @notifEventsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik Bildirimleri'**
  String get notifEventsTitle;

  /// No description provided for @notifEventsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni etkinlikler ve hatırlatmalar'**
  String get notifEventsSubtitle;

  /// No description provided for @notifApplicationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru Bildirimleri'**
  String get notifApplicationsTitle;

  /// No description provided for @notifApplicationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru durumu güncellemeleri'**
  String get notifApplicationsSubtitle;

  /// No description provided for @notifMessagesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj Bildirimleri'**
  String get notifMessagesTitle;

  /// No description provided for @notifMessagesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Grup sohbeti mesajları'**
  String get notifMessagesSubtitle;

  /// No description provided for @notifAnnouncementsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Duyurular'**
  String get notifAnnouncementsTitle;

  /// No description provided for @notifAnnouncementsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Genel duyurular ve haberler'**
  String get notifAnnouncementsSubtitle;

  /// No description provided for @notifSavedHint.
  ///
  /// In tr, this message translates to:
  /// **'Tercihleriniz bu cihazda saklanır.'**
  String get notifSavedHint;

  /// No description provided for @changePasswordConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Şifrenizi sıfırlamak için {email} adresine bir bağlantı göndereceğiz. Devam edilsin mi?'**
  String changePasswordConfirm(String email);

  /// No description provided for @passwordResetSent.
  ///
  /// In tr, this message translates to:
  /// **'Şifre sıfırlama bağlantısı e-postanıza gönderildi.'**
  String get passwordResetSent;

  /// No description provided for @emailUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınıza ait bir e-posta adresi bulunamadı.'**
  String get emailUnavailable;

  /// No description provided for @privacyIntro.
  ///
  /// In tr, this message translates to:
  /// **'Gizliliğiniz bizim için önemlidir. Bu politika, GönüllüNet\'i kullanırken hangi verileri topladığımızı ve nasıl kullandığımızı açıklar.'**
  String get privacyIntro;

  /// No description provided for @privacyDataTitle.
  ///
  /// In tr, this message translates to:
  /// **'Topladığımız Veriler'**
  String get privacyDataTitle;

  /// No description provided for @privacyDataBody.
  ///
  /// In tr, this message translates to:
  /// **'Hesap bilgileriniz (ad, e-posta, profil bilgileri), oluşturduğunuz gönderi ve etkinlikler ile konum tercihleriniz gibi uygulamayı kullanmak için sağladığınız verileri toplarız.'**
  String get privacyDataBody;

  /// No description provided for @privacyUsageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Verilerin Kullanımı'**
  String get privacyUsageTitle;

  /// No description provided for @privacyUsageBody.
  ///
  /// In tr, this message translates to:
  /// **'Verilerinizi yalnızca hizmeti sunmak, etkinlik başvurularını yönetmek ve deneyiminizi iyileştirmek için kullanırız. Verileriniz izniniz olmadan üçüncü taraflarla pazarlama amacıyla paylaşılmaz.'**
  String get privacyUsageBody;

  /// No description provided for @privacySecurityTitle.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik'**
  String get privacySecurityTitle;

  /// No description provided for @privacySecurityBody.
  ///
  /// In tr, this message translates to:
  /// **'Verileriniz Firebase altyapısında güvenli biçimde saklanır. Hesabınızı dilediğiniz zaman uygulama üzerinden silebilirsiniz.'**
  String get privacySecurityBody;

  /// No description provided for @privacyContactTitle.
  ///
  /// In tr, this message translates to:
  /// **'İletişim'**
  String get privacyContactTitle;

  /// No description provided for @privacyContactBody.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ile ilgili sorularınız için bizimle iletişime geçebilirsiniz: {email}'**
  String privacyContactBody(String email);

  /// No description provided for @privacyLastUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Son güncelleme: Haziran 2025'**
  String get privacyLastUpdated;

  /// No description provided for @rateAppFailed.
  ///
  /// In tr, this message translates to:
  /// **'Mağaza açılamadı.'**
  String get rateAppFailed;

  /// No description provided for @educationProfessionShort.
  ///
  /// In tr, this message translates to:
  /// **'Eğitim / Meslek'**
  String get educationProfessionShort;

  /// No description provided for @volunteerLevel.
  ///
  /// In tr, this message translates to:
  /// **'Gönüllü Seviyesi'**
  String get volunteerLevel;

  /// No description provided for @applications.
  ///
  /// In tr, this message translates to:
  /// **'Başvurular'**
  String get applications;

  /// No description provided for @phone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get phone;

  /// No description provided for @colApplicationStatus.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru Durumu'**
  String get colApplicationStatus;

  /// No description provided for @colApplicationDate.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru Tarihi'**
  String get colApplicationDate;

  /// No description provided for @statusApproved.
  ///
  /// In tr, this message translates to:
  /// **'Onaylandı'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In tr, this message translates to:
  /// **'Reddedildi'**
  String get statusRejected;

  /// No description provided for @statusPending.
  ///
  /// In tr, this message translates to:
  /// **'Bekliyor'**
  String get statusPending;

  /// No description provided for @excelCreateFailedException.
  ///
  /// In tr, this message translates to:
  /// **'Excel oluşturulamadı'**
  String get excelCreateFailedException;

  /// No description provided for @excelCreated.
  ///
  /// In tr, this message translates to:
  /// **'Excel dosyası oluşturuldu: {path}'**
  String excelCreated(String path);

  /// No description provided for @excelCreateError.
  ///
  /// In tr, this message translates to:
  /// **'Excel oluşturulamadı: {error}'**
  String excelCreateError(String error);

  /// No description provided for @noApprovedApplications.
  ///
  /// In tr, this message translates to:
  /// **'Onaylanmış başvuru bulunamadı.'**
  String get noApprovedApplications;

  /// No description provided for @participationListTitle.
  ///
  /// In tr, this message translates to:
  /// **'ETKİNLİK KATILIM LİSTESİ'**
  String get participationListTitle;

  /// No description provided for @createdDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Oluşturma Tarihi: {date}'**
  String createdDateLabel(String date);

  /// No description provided for @totalApprovedParticipants.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Onaylı Katılımcı: {count}'**
  String totalApprovedParticipants(Object count);

  /// No description provided for @colFullName.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get colFullName;

  /// No description provided for @pdfPageLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sayfa {current} / {total}'**
  String pdfPageLabel(Object current, Object total);

  /// No description provided for @pdfCreateError.
  ///
  /// In tr, this message translates to:
  /// **'PDF oluşturulamadı: {error}'**
  String pdfCreateError(String error);

  /// No description provided for @exportToExcel.
  ///
  /// In tr, this message translates to:
  /// **'Excel\'e Aktar'**
  String get exportToExcel;

  /// No description provided for @participationListPdf.
  ///
  /// In tr, this message translates to:
  /// **'Katılım Listesi (PDF)'**
  String get participationListPdf;

  /// No description provided for @noApplications.
  ///
  /// In tr, this message translates to:
  /// **'Henüz başvuru yok.'**
  String get noApplications;

  /// No description provided for @unnamed.
  ///
  /// In tr, this message translates to:
  /// **'İsimsiz'**
  String get unnamed;

  /// No description provided for @viewProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profili Gör'**
  String get viewProfile;

  /// No description provided for @reject.
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get reject;

  /// No description provided for @approve.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get approve;

  /// No description provided for @noPostsOwn.
  ///
  /// In tr, this message translates to:
  /// **'Henüz hiç gönderiniz yok'**
  String get noPostsOwn;

  /// No description provided for @shareFirstPost.
  ///
  /// In tr, this message translates to:
  /// **'Anasayfadaki + butonunu kullanarak\nilk gönderinizi paylaşabilirsiniz.'**
  String get shareFirstPost;

  /// No description provided for @postingNgoOnly.
  ///
  /// In tr, this message translates to:
  /// **'Gönderi paylaşımı sadece STK hesapları için kullanılabilir.'**
  String get postingNgoOnly;

  /// No description provided for @editPost.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiyi Düzenle'**
  String get editPost;

  /// No description provided for @titleFieldLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başlık'**
  String get titleFieldLabel;

  /// No description provided for @titleCannotBeEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Başlık boş olamaz'**
  String get titleCannotBeEmpty;

  /// No description provided for @descriptionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get descriptionLabel;

  /// No description provided for @deletePost.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiyi Sil'**
  String get deletePost;

  /// No description provided for @deletePostConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu gönderiyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'**
  String get deletePostConfirm;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @levelObserver.
  ///
  /// In tr, this message translates to:
  /// **'Gözlemci'**
  String get levelObserver;

  /// No description provided for @levelActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get levelActive;

  /// No description provided for @levelPioneer.
  ///
  /// In tr, this message translates to:
  /// **'Öncü'**
  String get levelPioneer;

  /// No description provided for @levelMaster.
  ///
  /// In tr, this message translates to:
  /// **'Usta'**
  String get levelMaster;

  /// No description provided for @levelLegend.
  ///
  /// In tr, this message translates to:
  /// **'Efsane'**
  String get levelLegend;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
