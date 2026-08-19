import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/responsive.dart';

Widget buildContactTile(BuildContext context, IconData icon, String title, String content) {
  return Container(
    padding: Responsive.padding(context, all: 16),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
    ),
    child: Row(
      children: [
        Container(
          width: Responsive.scale(context, 40),
          height: Responsive.scale(context, 40),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.grey.shade600, size: Responsive.scale(context, 20)),
        ),
        SizedBox(width: Responsive.scale(context, 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: Responsive.sp(context, 12),
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500)),
              Text(content,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: Responsive.sp(context, 14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.kTextColor)),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: Colors.grey.withOpacity(0.5)),
      ],
    ),
  );
}
