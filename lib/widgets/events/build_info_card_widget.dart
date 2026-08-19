import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/responsive.dart';

Widget buildInfoCard(BuildContext context, IconData icon, String title,
    String value, String subtitle, Color color) {
  return Container(
    padding: Responsive.padding(context, all: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(Responsive.scale(context, 20)),
      border: Border.all(
        color: Colors.grey.shade100,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: Responsive.padding(context, all: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(Responsive.scale(context, 12)),
          ),
          child: Icon(icon, color: color, size: Responsive.scale(context, 24)),
        ),
        SizedBox(height: Responsive.scale(context, 16)),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: Responsive.sp(context, 12),
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: Responsive.scale(context, 4)),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: Responsive.sp(context, 16),
            fontWeight: FontWeight.bold,
            color: AppColors.kTextColor,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: Responsive.sp(context, 12),
            color: Colors.grey.shade500,
          ),
        ),
      ],
    ),
  );
}
