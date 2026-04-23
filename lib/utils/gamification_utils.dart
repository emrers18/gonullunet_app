import 'package:flutter/material.dart';

class LevelInfo {
  final String title;
  final Color color;
  final int minXp;
  final int maxXp;

  LevelInfo({
    required this.title,
    required this.color,
    required this.minXp,
    required this.maxXp,
  });
}

class GamificationUtils {
  static final List<LevelInfo> levels = [
    LevelInfo(
      title: 'Gözlemci',
      color: Colors.blueGrey, // Metalik Gri
      minXp: 0,
      maxXp: 100,
    ),
    LevelInfo(
      title: 'Aktif Üye',
      color: Colors.green, // Canlı Yeşil
      minXp: 100,
      maxXp: 500,
    ),
    LevelInfo(
      title: 'Öncü',
      color: Colors.deepPurple, // Derin Mor
      minXp: 500,
      maxXp: 1500,
    ),
    LevelInfo(
      title: 'Usta',
      color: Colors.orange.shade700, // Parlak Bronz/Turuncu
      minXp: 1500,
      maxXp: 5000,
    ),
    LevelInfo(
      title: 'Efsane',
      color: const Color(0xFFFFD700), // Altın (Efsane)
      minXp: 5000,
      maxXp: 1000000, // Very high for max
    ),
  ];

  static LevelInfo getLevelInfo(int xp) {
    for (var i = levels.length - 1; i >= 0; i--) {
      if (xp >= levels[i].minXp) {
        return levels[i];
      }
    }
    return levels[0];
  }

  static double getProgress(int xp) {
    final currentLevel = getLevelInfo(xp);
    if (currentLevel.title == 'Efsane') return 1.0;

    final range = currentLevel.maxXp - currentLevel.minXp;
    final progress = xp - currentLevel.minXp;
    return (progress / range).clamp(0.0, 1.0);
  }
}
