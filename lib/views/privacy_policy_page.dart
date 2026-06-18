import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(
          l10n.privacyPolicy,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.privacyIntro,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: AppColors.kTextColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(l10n.privacyDataTitle, l10n.privacyDataBody),
          _buildSection(l10n.privacyUsageTitle, l10n.privacyUsageBody),
          _buildSection(l10n.privacySecurityTitle, l10n.privacySecurityBody),
          _buildSection(
            l10n.privacyContactTitle,
            l10n.privacyContactBody(l10n.aboutContactEmail),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.privacyLastUpdated,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.kTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              height: 1.6,
              color: AppColors.kTextColor.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}
