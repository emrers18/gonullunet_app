import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gonullunet_app/l10n/app_localizations.dart';
import '../logic/onboarding_cubit.dart';
import '../logic/onboarding_state.dart';
import '../utils/app_colors.dart';
import 'auth_gate.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(),
      child: const OnboardingView(),
    );
  }
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();



  late final AnimationController _floatController1;
  late final AnimationController _floatController2;

  List<Map<String, String>> _buildContents(AppLocalizations l10n) => [
        {
          "title": l10n.onboardTitle1,
          "desc": l10n.onboardDesc1,
          "image": "lib/assets/images/logo.png",
        },
        {
          "title": l10n.onboardTitle2,
          "desc": l10n.onboardDesc2,
          "image": "lib/assets/images/onboarding_2.png",
        },
        {
          "title": l10n.onboardTitle3,
          "desc": l10n.onboardDesc3,
          "image": "lib/assets/images/onboarding_3.png",
        },
      ];

  @override
  void initState() {
    super.initState();
    // Yüzen ikon animasyonları başlatılıyor
    _floatController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController1.dispose();
    _floatController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);
    final contents = _buildContents(l10n);

    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      body: BlocListener<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state.isCompleted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AuthGate()),
            );
          }
        },
        child: Stack(
          children: [
            // --- ARKA PLAN EFEKTLERİ (Yeni UI) ---
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade50.withOpacity(0.5),
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.kPrimaryColor.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              top: 160,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.kTealColor.withOpacity(0.1),
                ),
              ),
            ),

            // --- ANA İÇERİK ---
            SafeArea(
              child: Column(
                children: [
                  // Üst Bar: Atla Butonu
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.read<OnboardingCubit>().completeOnboarding();
                        },
                        child: Text(
                          l10n.onboardSkip,
                          style: GoogleFonts.dmSans(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // PageView (Kaydırılabilir Alan)
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: contents.length,
                      onPageChanged: (index) {
                        context.read<OnboardingCubit>().updateIndex(index);
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // HERO RESİM ALANI (Animasyonlu ve Gölgeli)
                              SizedBox(
                                height: 320,
                                width: 320,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Beyaz Arkaplan Dairesi
                                    Container(
                                      width: 260,
                                      height: 260,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.08),
                                            blurRadius: 40,
                                            offset: const Offset(0, 10),
                                          )
                                        ],
                                        border: Border.all(
                                            color: Colors.grey.shade100),
                                      ),
                                    ),

                                    // Resim
                                    Padding(
                                      padding: const EdgeInsets.all(40.0),
                                      child: Image.asset(
                                        contents[index]["image"]!,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.image,
                                                    size: 80,
                                                    color: AppColors.kSecondaryColor),
                                      ),
                                    ),

                                    // Yüzen İkon 1 (Kalp)
                                    AnimatedBuilder(
                                      animation: _floatController1,
                                      builder: (context, child) {
                                        return Positioned(
                                          top: 40 +
                                              (10 * _floatController1.value),
                                          right: 20,
                                          child: child!,
                                        );
                                      },
                                      child: _buildFloatingIcon(
                                          Icons.favorite, AppColors.kPrimaryColor),
                                    ),

                                    // Yüzen İkon 2 (Konum - Sadece ilk sayfada veya hepsinde olabilir)
                                    AnimatedBuilder(
                                      animation: _floatController2,
                                      builder: (context, child) {
                                        return Positioned(
                                          bottom: 60 +
                                              (10 * _floatController2.value),
                                          left: 10,
                                          child: child!,
                                        );
                                      },
                                      child: _buildFloatingIcon(
                                          Icons.location_on, AppColors.kSecondaryColor),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // BAŞLIK
                              _buildTitle(contents[index]["title"]!),

                              const SizedBox(height: 16),

                              // AÇIKLAMA
                              Text(
                                contents[index]["desc"]!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 18,
                                  color:
                                      const Color(0xFF6B7280), // subtext-light
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Alt Kontroller (Dots ve Button)
                  BlocBuilder<OnboardingCubit, OnboardingState>(
                    builder: (context, state) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                        child: Column(
                          children: [
                            // Noktalar (Dots)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                contents.length,
                                (index) => _buildDot(index, state.currentIndex),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Ana Buton
                            SizedBox(
                              width: double.infinity,
                              height: 64, // Tasarımdaki büyük buton boyutu
                              child: ElevatedButton(
                                onPressed: () {
                                  if (state.currentIndex ==
                                      contents.length - 1) {
                                    context
                                        .read<OnboardingCubit>()
                                        .completeOnboarding();
                                  } else {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves
                                          .easeInOut, // Daha yumuşak geçiş
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.kPrimaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 10,
                                  shadowColor: AppColors.kPrimaryColor
                                      .withOpacity(0.4), // Glow efekti
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      state.currentIndex == contents.length - 1
                                          ? l10n.onboardStart
                                          : l10n.onboardContinue,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Yüzen İkon Widget'ı
  Widget _buildFloatingIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  // Sayfa Gösterge Noktası Widget'ı
  Widget _buildDot(int index, int currentIndex) {
    bool isActive = index == currentIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: isActive ? 32 : 8, // Aktifse geniş, pasifse kare
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.kPrimaryColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

Widget _buildTitle(String title) {
  // Başlığı '\n' karakterinden ikiye bölüyoruz
  final parts = title.split('\n');

  // Eğer başlıkta '\n' yoksa veya tek parça ise düz döndür
  if (parts.length < 2) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: GoogleFonts.dmSans(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
        color: const Color(0xFF1F2937),
      ),
    );
  }

  // RichText ile parçalı stil uygulama
  return RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      style: GoogleFonts.dmSans(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
        color: const Color(0xFF1F2937), // Varsayılan renk (Siyah)
      ),
      children: [
        TextSpan(text: "${parts[0]}\n"), // İlk satır + alt satıra geçiş
        TextSpan(
          text: parts[1], // İkinci satır
          style:
              const TextStyle(color: AppColors.kPrimaryColor), // Turuncu renk
        ),
        // Eğer 2'den fazla satır varsa geri kalanını da ekleyebilirsiniz
        if (parts.length > 2)
          TextSpan(text: "\n${parts.sublist(2).join('\n')}"),
      ],
    ),
  );
}
