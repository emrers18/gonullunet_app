import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/responsive.dart';

Widget buildStatItem(BuildContext context, String value, String label) {
  return Column(
    children: [
      Text(
        value,
        style: GoogleFonts.plusJakartaSans(
          fontSize: Responsive.sp(context, 18),
          fontWeight: FontWeight.bold,
          color: AppColors.kTextColor,
        ),
      ),
      Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: Responsive.sp(context, 12),
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade500,
        ),
      ),
    ],
  );
}
