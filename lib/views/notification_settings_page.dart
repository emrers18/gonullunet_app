import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';
import 'package:gonullunet_app/utils/responsive.dart';

/// Bildirim tercihleri ekranı. Tercihler yerel olarak SharedPreferences'ta
/// saklanır.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  static const String _kPush = 'notif_push';
  static const String _kEvents = 'notif_events';
  static const String _kApplications = 'notif_applications';
  static const String _kMessages = 'notif_messages';
  static const String _kAnnouncements = 'notif_announcements';

  bool _loading = true;
  bool _push = true;
  bool _events = true;
  bool _applications = true;
  bool _messages = true;
  bool _announcements = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _push = prefs.getBool(_kPush) ?? true;
      _events = prefs.getBool(_kEvents) ?? true;
      _applications = prefs.getBool(_kApplications) ?? true;
      _messages = prefs.getBool(_kMessages) ?? true;
      _announcements = prefs.getBool(_kAnnouncements) ?? true;
      _loading = false;
    });
  }

  Future<void> _setPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(
          l10n.notificationSettings,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? const AppLoadingCenter()
          : ListView(
              padding: Responsive.padding(context, vertical: 16),
              children: [
                _buildTile(
                  title: l10n.notifPushTitle,
                  subtitle: l10n.notifPushSubtitle,
                  icon: Icons.notifications_active_outlined,
                  value: _push,
                  onChanged: (v) {
                    setState(() => _push = v);
                    _setPref(_kPush, v);
                  },
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _buildTile(
                  title: l10n.notifEventsTitle,
                  subtitle: l10n.notifEventsSubtitle,
                  icon: Icons.event_outlined,
                  value: _events,
                  enabled: _push,
                  onChanged: (v) {
                    setState(() => _events = v);
                    _setPref(_kEvents, v);
                  },
                ),
                _buildTile(
                  title: l10n.notifApplicationsTitle,
                  subtitle: l10n.notifApplicationsSubtitle,
                  icon: Icons.assignment_outlined,
                  value: _applications,
                  enabled: _push,
                  onChanged: (v) {
                    setState(() => _applications = v);
                    _setPref(_kApplications, v);
                  },
                ),
                _buildTile(
                  title: l10n.notifMessagesTitle,
                  subtitle: l10n.notifMessagesSubtitle,
                  icon: Icons.chat_bubble_outline,
                  value: _messages,
                  enabled: _push,
                  onChanged: (v) {
                    setState(() => _messages = v);
                    _setPref(_kMessages, v);
                  },
                ),
                _buildTile(
                  title: l10n.notifAnnouncementsTitle,
                  subtitle: l10n.notifAnnouncementsSubtitle,
                  icon: Icons.campaign_outlined,
                  value: _announcements,
                  enabled: _push,
                  onChanged: (v) {
                    setState(() => _announcements = v);
                    _setPref(_kAnnouncements, v);
                  },
                ),
                Padding(
                  padding: Responsive.padding(context,
                      left: 20, top: 16, right: 20, bottom: 0),
                  child: Text(
                    l10n.notifSavedHint,
                    style: GoogleFonts.inter(
                      fontSize: Responsive.sp(context, 12),
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return SwitchListTile(
      value: value && enabled,
      onChanged: enabled ? onChanged : null,
      activeColor: AppColors.kPrimaryColor,
      contentPadding: Responsive.padding(context, horizontal: 20, vertical: 4),
      secondary: Container(
        padding: Responsive.padding(context, all: 8),
        decoration: BoxDecoration(
          color: AppColors.kPrimaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Responsive.scale(context, 10)),
        ),
        child: Icon(icon, color: AppColors.kPrimaryColor, size: Responsive.scale(context, 20)),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: Responsive.sp(context, 12), color: Colors.grey.shade500),
      ),
    );
  }
}
