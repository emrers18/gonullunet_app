import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/responsive.dart';

Widget buildSectionTitle(BuildContext context, IconData icon, String title) {
  return Row(
    children: [
      Icon(icon, color: AppColors.kPrimaryColor, size: Responsive.scale(context, 20)),
      SizedBox(width: Responsive.scale(context, 8)),
      Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: Responsive.sp(context, 18),
          fontWeight: FontWeight.bold,
          color: AppColors.kTextColor,
        ),
      ),
    ],
  );
}
