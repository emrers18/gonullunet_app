import 'package:flutter/material.dart';
import 'package:gonullunet_app/utils/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Ayarlar",
          style: TextStyle(
              color: AppColors.primaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSettingItem(context, "Şifre Değiştir", Icons.lock_outline),
          _buildSettingItem(
              context, "Bildirim Ayarları", Icons.notifications_none),
          _buildSettingItem(
              context, "Gizlilik Politikası", Icons.privacy_tip_outlined),
          _buildSettingItem(context, "Hakkımızda", Icons.info_outline),
          _buildSettingItem(
              context, "Uygulamayı Değerlendir", Icons.star_outline),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title yakında eklenecek!")),
          );
        },
      ),
    );
  }
}
