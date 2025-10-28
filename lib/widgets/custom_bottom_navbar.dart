import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// [currentIndex] parametresi o an seçili olan sayfanın index'ini alır.
/// [onTap] parametresi ise bir öğeye tıklandığında hangi fonksiyonun
/// çalışacağını belirler (genellikle sayfa değiştiren bir `setState`).
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: AppColors.accentColor,
      unselectedItemColor: Colors.grey[600],
      backgroundColor: AppColors.textColor,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      type: BottomNavigationBarType
          .fixed, // Tip: fixed, 4 öğe de sığar ve yerinde sabit kalır
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Anasayfa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Etkinlikler',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.corporate_fare_outlined),
          activeIcon: Icon(Icons.corporate_fare),
          label: 'STK\'lar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
