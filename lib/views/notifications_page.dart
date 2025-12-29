import 'package:flutter/material.dart';
import 'package:gonullunet_app/utils/app_colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Bildirimler",
          style: TextStyle(
              color: AppColors.primaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Henüz bildiriminiz yok.",
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
