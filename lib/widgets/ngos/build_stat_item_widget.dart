import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildStatItem(String value, String label) {
  return Column(
    children: [
      Text(
        value,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF181210),
        ),
      ),
      Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade500,
        ),
      ),
    ],
  );
}
