import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gonullunet_app/utils/app_colors.dart';

import '../logic/onboarding_cubit.dart';
import '../logic/onboarding_state.dart';
import '../main.dart';

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

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();

  final List<Map<String, String>> _contents = [
    {
      "title": "GönüllüNet'e Hoş Geldin",
      "desc":
          "Çevrendeki iyilik hareketlerini keşfet, topluluğa katıl ve fark yaratmaya hemen başla.",
      "image": "assets/images/logo.png",
    },
    {
      "title": "Etkinlikleri Keşfet",
      "desc":
          "Sana en yakın gönüllülük etkinliklerini harita üzerinde bul ve ilgi alanına göre filtrele.",
      "image": "assets/images/onboarding_2.png",
    },
    {
      "title": "Birlikte Güçlüyüz",
      "desc":
          "STK'lar ve gönüllülerle bir araya gelerek büyük değişimlerin bir parçası ol.",
      "image": "assets/images/onboarding_3.png",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state.isCompleted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AuthGate()),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.read<OnboardingCubit>().completeOnboarding();
                  },
                  child: const Text(
                    "Atla",
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _contents.length,
                  onPageChanged: (index) {
                    context.read<OnboardingCubit>().updateIndex(index);
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 250,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == 0
                                  ? AppColors.lightPrimaryColor
                                  : Colors.transparent,
                            ),
                            padding: index == 0
                                ? const EdgeInsets.all(40)
                                : const EdgeInsets.all(10),
                            child: Image.asset(
                              _contents[index]["image"]!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 80,
                                    color: AppColors.secondaryText);
                              },
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            _contents[index]["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _contents[index]["desc"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.secondaryText,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _contents.length,
                            (index) => _buildDot(index, state.currentIndex),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              if (state.currentIndex == _contents.length - 1) {
                                // Son sayfadaysa bitirir
                                context
                                    .read<OnboardingCubit>()
                                    .completeOnboarding();
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                shadowColor: AppColors.primaryColor),
                            child: Text(
                              state.currentIndex == _contents.length - 1
                                  ? "Hemen Başla"
                                  : "İleri",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
      ),
    );
  }

  Widget _buildDot(int index, int currentIndex) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 8,
      width: currentIndex == index ? 24 : 8,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: currentIndex == index
            ? AppColors.primaryColor
            : AppColors.lightPrimaryColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
