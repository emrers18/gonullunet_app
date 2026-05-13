import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/gamification_utils.dart';

class LevelBadge extends StatelessWidget {
  final int xp;
  final bool showTitle;
  final double iconSize;
  final double fontSize;
  final EdgeInsets padding;

  const LevelBadge({
    super.key,
    required this.xp,
    this.showTitle = true,
    this.iconSize = 14,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    final level = GamificationUtils.getLevelInfo(xp);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: level.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: level.color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: level.color.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            level.icon,
            size: iconSize,
            color: level.color,
          ),
          if (showTitle) ...[
            const SizedBox(width: 4),
            Text(
              level.title,
              style: GoogleFonts.plusJakartaSans(
                color: level.color,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
