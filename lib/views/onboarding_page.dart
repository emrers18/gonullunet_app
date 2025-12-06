import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/views/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _contents = [
    {
      "title": "GönüllüNet'e Hoş Geldin",
      "desc":
          "Çevrendeki iyilik hareketlerini keşfet, topluluğa katıl ve fark yaratmaya hemen başla.",
      "image": "lib/assets/images/logo.png",
    },
    {
      "title": "Etkinlikleri Keşfet",
      "desc":
          "Sana en yakın gönüllülük etkinliklerini harita üzerinde bul ve ilgi alanına göre filtrele.",
      "image": "lib/assets/images/onboarding_2.png",
    },
    {
      "title": "Birlikte Güçlüyüz",
      "desc":
          "STK'lar ve gönüllülerle bir araya gelerek büyük değişimlerin bir parçası ol.",
      "image": "lib/assets/images/onboarding_3.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _navigateToLogin(),
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
                controller: _controller,
                itemCount: _contents.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
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
                                ? AppColors.lightPrimaryColor.withOpacity(0.3)
                                : Colors.transparent,
                          ),
                          padding: index == 0
                              ? const EdgeInsets.all(40)
                              : const EdgeInsets.all(10),
                          child: Image.asset(
                            _contents[index]["image"]!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              //foto bulamazsa error yerine logo göstersin
                              return Icon(
                                Icons.image_not_supported_outlined,
                                size: 80,
                                color: AppColors.secondaryText.withOpacity(0.5),
                              );
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
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _contents.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentIndex == _contents.length - 1) {
                          _navigateToLogin();
                        } else {
                          _controller.nextPage(
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
                        shadowColor: AppColors.primaryColor.withOpacity(0.4),
                      ),
                      child: Text(
                        _currentIndex == _contents.length - 1
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 8,
      width: _currentIndex == index ? 24 : 8,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: _currentIndex == index
            ? AppColors.primaryColor
            : AppColors.lightPrimaryColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _navigateToLogin() async {
    // kullanıcının onboarding'i gördüğünü cihaz hafızasına kaydeder
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showOnboarding', false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }
}
