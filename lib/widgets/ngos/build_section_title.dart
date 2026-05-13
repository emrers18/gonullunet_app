import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gonullunet_app/utils/app_colors.dart';

Widget buildSectionTitle(BuildContext context, IconData icon, String title) {
  return Row(
    children: [
      Icon(icon, color: AppColors.kPrimaryColor, size: 20),
      const SizedBox(width: 8),
      Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.kTextColor,
        ),
      ),
    ],
  );
}
