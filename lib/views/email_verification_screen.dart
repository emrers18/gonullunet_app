import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';
import 'package:gonullunet_app/utils/responsive.dart';

import 'auth_gate.dart';

/// E-posta doğrulama ekranı.
///
/// Kullanıcı kayıt olduktan hemen sonra bu ekrana yönlendirilir.
/// Ekran:
/// - Her 3 saniyede bir [user.reload()] → [user.emailVerified] kontrol eder.
/// - 3 dakikalık geriye sayan bir sayaç (countdown) gösterir.
/// - Süre dolduğunda periyodik kontrol durur ve yeniden link gönderme
///   seçeneği sunulur.
/// - Firebase "too-many-requests" hatasını önlemek için buton
///   basımları [_canResend] flag'i ile sınırlandırılır.
class EmailVerificationScreen extends StatefulWidget {
  /// Doğrulama beklenen e-posta adresi (bilgi metni için gösterilir).
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // Renk sabitleri – GönüllüNet marka paleti
  // ─────────────────────────────────────────────────────────────────────────
  static const Color _kPrimary = Color(0xFFFF6B35); // Turuncu
  static const Color _kSecondary = Color(0xFF004E89); // Koyu Mavi
  static const Color _kBg = Color(0xFFF7F9FC); // Açık Gri Arka Plan
  static const Color _kText = Color(0xFF1F2937); // Koyu Metin
  static const Color _kSubtext = Color(0xFF6B7280); // Alt Metin

  // ─────────────────────────────────────────────────────────────────────────
  // Zamanlayıcı değişkenleri
  // ─────────────────────────────────────────────────────────────────────────

  /// Toplam süre: 3 dakika = 180 saniye
  static const int _totalSeconds = 180;

  /// Kalan süre (saniye cinsinden, geriye sayar)
  int _remainingSeconds = _totalSeconds;

  /// Her 1 saniyede bir tetiklenen countdown timer
  Timer? _countdownTimer;

  /// Her 3 saniyede bir e-posta doğrulama durumunu kontrol eden timer
  Timer? _verificationCheckTimer;

  // ─────────────────────────────────────────────────────────────────────────
  // Durum bayrakları
  // ─────────────────────────────────────────────────────────────────────────

  /// Süre dolup dolmadığını tutar
  bool _isTimedOut = false;

  /// Yeniden gönderme butonunun aktif/pasif durumu
  /// (too-many-requests hatasını önlemek için cooldown mekanizması)
  bool _canResend = true;

  /// Yeniden gönderme için kalan cooldown süresi
  int _resendCooldown = 0;

  /// Cooldown zamanlayıcısı
  Timer? _resendCooldownTimer;

  /// Genel yükleme göstergesi (resend işlemi sırasında)
  bool _isLoading = false;

  // ─────────────────────────────────────────────────────────────────────────
  // Animasyon – rotasyonlu zarf ikonu
  // ─────────────────────────────────────────────────────────────────────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    // Pulse animasyonu kur
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Zamanlayıcıları başlat
    _startCountdownTimer();
    _startVerificationCheckTimer();
  }

  @override
  void dispose() {
    // ÖNEMLI: Memory leak'i önlemek için tüm Timer nesneleri temizlenir.
    _countdownTimer?.cancel();
    _verificationCheckTimer?.cancel();
    _resendCooldownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Timer başlatma metotları
  // ─────────────────────────────────────────────────────────────────────────

  /// Her saniye geri sayımı azaltır; süre dolduğunda timeout olayını tetikler.
  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _onTimeout();
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
    });
  }

  /// Her 3 saniyede bir Firebase'den güncel kullanıcı durumu alır.
  void _startVerificationCheckTimer() {
    _verificationCheckTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerified(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Ana kontrol mantığı
  // ─────────────────────────────────────────────────────────────────────────

  /// Firebase'den kullanıcı profilini yeniler ve doğrulama durumunu kontrol eder.
  Future<void> _checkEmailVerified() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Sunucudan güncel e-posta doğrulama durumunu çek
      await user.reload();

      // Reload sonrası güncel user nesnesini yeniden al
      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser?.emailVerified == true) {
        // ID token'ı zorla yenile ki email_verified: true claim'i Firestore kuralları tarafından görülebilsin
        await refreshedUser?.getIdToken(true);
        _stopAllTimers();
        if (mounted) {
          _navigateToHome();
        }
      }
    } catch (_) {
      // Sessizce yoksay – periyodik kontrol devam eder
    }
  }

  /// Süre dolduğunda çağrılır: periyodik kontrol durdurulur, UI güncellenir.
  void _onTimeout() {
    _verificationCheckTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _isTimedOut = true;
    });
  }

  /// Tüm aktif zamanlayıcıları durdurur.
  void _stopAllTimers() {
    _countdownTimer?.cancel();
    _verificationCheckTimer?.cancel();
    _resendCooldownTimer?.cancel();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Eylemler
  // ─────────────────────────────────────────────────────────────────────────

  /// Yeniden doğrulama e-postası gönderir ve cooldown başlatır.
  Future<void> _resendVerificationEmail() async {
    if (!_canResend || _isLoading) return;

    setState(() {
      _isLoading = true;
      _canResend = false;
    });

    try {
      final l10n = AppLocalizations.of(context);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception(l10n.userSessionNotFound);

      await user.sendEmailVerification();

      if (!mounted) return;

      // Başarıyla gönderildi
      _showSnackBar(l10n.verificationEmailResent, isError: false);

      // Eğer timeout olduysa, yeni 3 dakikalık sayacı başlat
      if (_isTimedOut) {
        setState(() {
          _isTimedOut = false;
          _remainingSeconds = _totalSeconds;
        });
        _startCountdownTimer();
        _startVerificationCheckTimer();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (e.code == 'too-many-requests') {
        _showSnackBar(
          l10n.tooManyRequests,
          isError: true,
        );
      } else {
        _showSnackBar(
          l10n.emailSendFailed(e.message ?? e.code),
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context).unexpectedError('$e'),
          isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      // 60 saniyelik cooldown başlat – "too-many-requests" önlemi
      _startResendCooldown(seconds: 60);
    }
  }

  /// Kullanıcı kayıt sürecini iptal edip Firebase hesabını siler ve çıkış yapar.
  Future<void> _cancelAndGoBack() async {
    _stopAllTimers();

    try {
      // Doğrulanmamış kullanıcıyı temizle
      await FirebaseAuth.instance.currentUser?.delete();
    } catch (_) {
      // Silme başarısız olursa sign-out yap; AuthGate LoginPage'e yönlendirir
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    // AuthGate'teki StreamBuilder auth state değişimini algılayıp
    // otomatik olarak LoginPage'e yönlendirecek.
    // Route temizlemesi gerekmez.
  }

  /// E-posta doğrulandığında AuthGate'e yönlendirir.
  /// AuthGate'in StreamBuilder'ı user.emailVerified durumuna göre
  /// MainPage veya LoginPage'i otomatik seçer.
  /// AuthGate stack'te kalmalı ki ilerideki signOut() çağrıları da çalışsın.
  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  /// 60 saniyelik yeniden gönderim cooldown'u başlatır.
  void _startResendCooldown({required int seconds}) {
    setState(() {
      _resendCooldown = seconds;
      _canResend = false;
    });
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() {
          _resendCooldown = 0;
          _canResend = true;
        });
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: isError ? Colors.redAccent : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scale(context, 12))),
        margin: Responsive.padding(context, all: 16),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Yardımcı getter'lar
  // ─────────────────────────────────────────────────────────────────────────

  /// Geri sayımı "MM:SS" formatında döndürür.
  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// İlerleme yüzdesi (1.0 → 0.0 arası): arc için kullanılır.
  double get _progress => _remainingSeconds / _totalSeconds;

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: Responsive.padding(context, horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Geri / İptal Butonu ──────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: _buildBackButton(),
              ),

              SizedBox(height: Responsive.scale(context, 24)),

              // ── Animasyonlu Zarf İkonu ───────────────────────────────────
              _buildEnvelopeIcon(),

              SizedBox(height: Responsive.scale(context, 28)),

              // ── Başlık ───────────────────────────────────────────────────
              Text(
                AppLocalizations.of(context).verifyYourEmail,
                style: GoogleFonts.inter(
                  fontSize: Responsive.sp(context, 24),
                  fontWeight: FontWeight.w700,
                  color: _kText,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: Responsive.scale(context, 12)),

              // ── Açıklama ──────────────────────────────────────────────────
              _buildDescriptionCard(),

              SizedBox(height: Responsive.scale(context, 32)),

              // ── Geri Sayım Göstergesi ─────────────────────────────────────
              _buildCountdownWidget(),

              SizedBox(height: Responsive.scale(context, 32)),

              // ── Durum Kartı (Timeout / Normal) ────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: _isTimedOut
                    ? _buildTimeoutCard(key: const ValueKey('timeout'))
                    : _buildWaitingCard(key: const ValueKey('waiting')),
              ),

              SizedBox(height: Responsive.scale(context, 24)),

              // ── Gönder / Yeniden Gönder Butonu ───────────────────────────
              _buildResendButton(),

              SizedBox(height: Responsive.scale(context, 16)),

              // ── Vazgeç ───────────────────────────────────────────────────
              _buildCancelButton(),

              SizedBox(height: Responsive.scale(context, 24)),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Widget yardımcıları
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: _kText),
        onPressed: _cancelAndGoBack,
        tooltip: AppLocalizations.of(context).cancelRegistrationTooltip,
      ),
    );
  }

  Widget _buildEnvelopeIcon() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plan halkası
          Container(
            width: Responsive.scale(context, 120),
            height: Responsive.scale(context, 120),
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
          // Orta daire
          Container(
            width: Responsive.scale(context, 88),
            height: Responsive.scale(context, 88),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _kPrimary,
                  _kPrimary.withOpacity(0.75),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _kPrimary.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(Icons.mark_email_unread_rounded,
                color: Colors.white, size: Responsive.scale(context, 40)),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: Responsive.padding(context, all: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: Responsive.padding(context, all: 8),
                decoration: BoxDecoration(
                  color: _kSecondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(Responsive.scale(context, 10)),
                ),
                child: Icon(Icons.email_outlined,
                    size: Responsive.scale(context, 18), color: _kSecondary),
              ),
              SizedBox(width: Responsive.scale(context, 12)),
              Expanded(
                child: Text(
                  widget.email,
                  style: GoogleFonts.inter(
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w600,
                    color: _kSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.scale(context, 12)),
          Text(
            AppLocalizations.of(context).verificationLinkSent,
            style: GoogleFonts.inter(
              fontSize: Responsive.sp(context, 13),
              color: _kSubtext,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownWidget() {
    // Renk: yeşil → sarı → kırmızı geçişi
    final Color arcColor = _isTimedOut
        ? Colors.red.shade400
        : _progress > 0.5
            ? Colors.green.shade500
            : _progress > 0.25
                ? Colors.orange.shade500
                : Colors.red.shade400;

    return Column(
      children: [
        SizedBox(
          width: Responsive.scale(context, 140),
          height: Responsive.scale(context, 140),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Arka plan daire
              SizedBox.expand(
                child: CustomPaint(
                  painter: _ArcPainter(
                    progress: _isTimedOut ? 0 : _progress,
                    color: arcColor,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
              // İç içerik
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isTimedOut ? '00:00' : _formattedTime,
                    style: GoogleFonts.inter(
                      fontSize: Responsive.sp(context, 28),
                      fontWeight: FontWeight.w700,
                      color: _isTimedOut ? Colors.red.shade400 : _kText,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    _isTimedOut
                        ? AppLocalizations.of(context).countdownExpired
                        : AppLocalizations.of(context).countdownRemaining,
                    style: GoogleFonts.inter(
                      fontSize: Responsive.sp(context, 11),
                      color: _kSubtext,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingCard({Key? key}) {
    return Container(
      key: key,
      padding: Responsive.padding(context, all: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          SizedBox(
            width: Responsive.scale(context, 20),
            height: Responsive.scale(context, 20),
            child: AppLoadingIndicator(size: Responsive.scale(context, 20)),
          ),
          SizedBox(width: Responsive.scale(context, 12)),
          Expanded(
            child: Text(
              AppLocalizations.of(context).checkInbox,
              style: GoogleFonts.inter(
                fontSize: Responsive.sp(context, 13),
                color: Colors.blue.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeoutCard({Key? key}) {
    return Container(
      key: key,
      padding: Responsive.padding(context, all: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.red.shade500, size: Responsive.scale(context, 22)),
          SizedBox(width: Responsive.scale(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).timeUp,
                  style: GoogleFonts.inter(
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade700,
                  ),
                ),
                SizedBox(height: Responsive.scale(context, 4)),
                Text(
                  AppLocalizations.of(context).linkExpiredDesc,
                  style: GoogleFonts.inter(
                    fontSize: Responsive.sp(context, 13),
                    color: Colors.red.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResendButton() {
    final l10n = AppLocalizations.of(context);
    final bool isActive = _canResend && !_isLoading;
    final String label = _isLoading
        ? l10n.sending
        : _isTimedOut
            ? l10n.sendNewLink
            : _canResend
                ? l10n.resendLink
                : l10n.resendIn(_resendCooldown);

    return SizedBox(
      width: double.infinity,
      height: Responsive.scale(context, 54),
      child: ElevatedButton(
        onPressed: isActive ? _resendVerificationEmail : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade200,
          disabledForegroundColor: Colors.grey.shade500,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scale(context, 16))),
          elevation: isActive ? 6 : 0,
          shadowColor: _kPrimary.withOpacity(0.4),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: Responsive.scale(context, 22),
                  height: Responsive.scale(context, 22),
                  child: AppLoadingIndicator(size: Responsive.scale(context, 22)),
                )
              : Row(
                  key: ValueKey(label),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isTimedOut ? Icons.refresh_rounded : Icons.send_rounded,
                      size: Responsive.scale(context, 18),
                    ),
                    SizedBox(width: Responsive.scale(context, 8)),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: Responsive.sp(context, 15),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton.icon(
      onPressed: _cancelAndGoBack,
      icon: Icon(Icons.close_rounded, size: Responsive.scale(context, 16), color: Colors.grey.shade500),
      label: Text(
        AppLocalizations.of(context).cancelReturnLogin,
        style: GoogleFonts.inter(
          color: Colors.grey.shade500,
          fontSize: Responsive.sp(context, 13),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Özel Arc (yay) çizici – geri sayım progress ring'i için
// ─────────────────────────────────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final Color color;
  final Color backgroundColor;

  const _ArcPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;

    // Arka plan yayı (gri)
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // İlerleme yayı
    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Saat 12'den başla
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
