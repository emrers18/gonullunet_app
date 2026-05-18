import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gonullunet_app/services/auth.dart';
import 'package:gonullunet_app/views/login_page.dart';
import 'package:gonullunet_app/views/main_page.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        // 1. Durum: Bağlantı bekleniyor
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: AppLoadingCenter(),
          );
        }

        // 2. Durum: Kullanıcı Giriş Yapmış -> Ana Sayfa
        if (snapshot.hasData) {
          return const MainPage();
        }

        // 3. Durum: Kullanıcı Yok -> Giriş Sayfası
        return const LoginPage();
      },
    );
  }
}
