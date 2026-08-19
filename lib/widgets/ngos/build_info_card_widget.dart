import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/responsive.dart';

Widget buildInfoCard(BuildContext context, String title, String content, IconData icon,
    Color iconColor, Color bgColor) {
  return Container(
    padding: Responsive.padding(context, all: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: Responsive.scale(context, 40),
          height: Responsive.scale(context, 40),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: Responsive.scale(context, 20)),
        ),
        SizedBox(height: Responsive.scale(context, 12)),
        Text(title,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: Responsive.sp(context, 14),
                color: AppColors.kTextColor)),
        SizedBox(height: Responsive.scale(context, 4)),
        Text(
          content,
          style: TextStyle(
              fontSize: Responsive.sp(context, 12),
              color: Colors.grey.shade500,
              height: 1.4),
        ),
      ],
    ),
  );
}
