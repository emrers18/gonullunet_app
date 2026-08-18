import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gonullunet_app/models/user_model.dart';
import 'package:gonullunet_app/services/auth.dart';
import 'package:gonullunet_app/views/edit_ngo_profile_page.dart';
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

        // 2. Durum: Kullanıcı Yok -> Giriş Sayfası
        final user = snapshot.data;
        if (user == null) {
          return const LoginPage();
        }

        // 3. Durum: Kullanıcı Giriş Yapmış -> profil tamamlanmış mı kontrol et
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: AppLoadingCenter(),
              );
            }

            if (profileSnapshot.hasData && profileSnapshot.data!.exists) {
              final profile = UserModel.fromFirestore(profileSnapshot.data!);
              // STK profili eksikse, uygulamanın geri kalanına (Kurumlar
              // sekmesi dahil) erişmeden önce profili tamamlaması zorunlu.
              if (!profile.isNgoProfileComplete) {
                return const EditNgoProfilePage(forceComplete: true);
              }
            }

            return const MainPage();
          },
        );
      },
    );
  }
}
