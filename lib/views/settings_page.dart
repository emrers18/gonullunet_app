import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/services/auth.dart';
import 'package:gonullunet_app/services/firebase_error_translator.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';
import 'about_page.dart';
import 'notification_settings_page.dart';
import 'privacy_policy_page.dart';
import 'package:gonullunet_app/utils/responsive.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          ListView(
            padding: Responsive.padding(context, vertical: 20),
            children: [
              _buildSectionHeader(context, l10n.generalSettings),
              _buildSettingItem(
                context,
                l10n.changePassword,
                Icons.lock_outline,
                onTap: () => _sendPasswordReset(context),
              ),
              _buildSettingItem(
                context,
                l10n.notificationSettings,
                Icons.notifications_none,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationSettingsPage()),
                ),
              ),

              SizedBox(height: Responsive.scale(context, 24)),
              _buildSectionHeader(context, l10n.accountSettingsSection),
              _buildSettingItem(
                context,
                l10n.deleteAccount,
                Icons.delete_outline,
                isDestructive: true,
                onTap: () => _showDeleteConfirmation(context),
              ),

              SizedBox(height: Responsive.scale(context, 24)),
              _buildSectionHeader(context, l10n.application),
              _buildSettingItem(
                context,
                l10n.privacyPolicy,
                Icons.privacy_tip_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyPage()),
                ),
              ),
              _buildSettingItem(
                context,
                l10n.aboutUs,
                Icons.info_outline,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                ),
              ),
              _buildSettingItem(
                context,
                l10n.rateApp,
                Icons.star_outline,
                onTap: () => _rateApp(context),
              ),
            ],
          ),
          if (_isDeleting)
            Container(
              color: Colors.black26,
              child: Center(
                child: AppLoadingIndicator(size: Responsive.scale(context, 48)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: Responsive.padding(context, left: 20, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: Responsive.sp(context, 12),
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    IconData icon, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: Responsive.padding(context, horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: Responsive.padding(context, horizontal: 20, vertical: 4),
        leading: Container(
          padding: Responsive.padding(context, all: 8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.shade50
                : AppColors.kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Responsive.scale(context, 10)),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : AppColors.kPrimaryColor,
            size: Responsive.scale(context, 20),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        trailing:
            Icon(Icons.arrow_forward_ios, size: Responsive.scale(context, 14), color: Colors.grey),
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).comingSoon(title)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
      ),
    );
  }

  Future<void> _sendPasswordReset(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final email = FirebaseAuth.instance.currentUser?.email;

    if (email == null || email.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.emailUnavailable),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scale(context, 16))),
        title: Text(l10n.changePassword,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(l10n.changePasswordConfirm(email),
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel,
                style: GoogleFonts.inter(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.send,
                style: GoogleFonts.inter(
                    color: AppColors.kPrimaryColor,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.passwordResetSent),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content:
              Text(AppMessages.resolve(context, FirebaseErrorTranslator.translate(e))),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _rateApp(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      } else {
        await inAppReview.openStoreListing();
      }
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.rateAppFailed),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deleteAccountConfirm,
              style: GoogleFonts.inter(),
            ),
            SizedBox(height: Responsive.scale(context, 8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                  child: Text(
                    l10n.cancelUpper,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: Responsive.scale(context, 8)),
                TextButton(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    setState(() => _isDeleting = true);
                    try {
                      await Auth().deleteAccount();
                    } catch (e) {
                      if (mounted) {
                        setState(() => _isDeleting = false);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                AppLocalizations.of(context).errorOccurred('$e')),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    l10n.yesDelete,
                    style: GoogleFonts.inter(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade900,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(days: 1), // İptale basılmadıkça gitmesin
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scale(context, 12))),
        margin: Responsive.padding(context, all: 16),
      ),
    );
  }
}
