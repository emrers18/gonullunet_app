import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildInfoCard(
    IconData icon, String title, String value, String subtitle, Color color) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 16),
        Text(title,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: const Color(0xFF9CA3AF))),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937))),
        Text(subtitle,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: const Color(0xFF9CA3AF))),
      ],
    ),
  );
}
