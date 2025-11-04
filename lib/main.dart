import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gonullunet_app/services/auth.dart';
import 'package:gonullunet_app/views/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gonullunet_app/views/main_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          //veri gelmiyorsa bekleme kısmı
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          //veri geldi ve kullanıcı giriş yapmış ise
          if (snapshot.hasData && snapshot.data != null) {
            return const MainPage();
          }
          // veri gelmiş ama kullanıcı giriş yapmamış ise
          return const LoginPage();
        });
  }
}
