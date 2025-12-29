import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gonullunet_app/logic/profile_cubit.dart';
import 'package:gonullunet_app/repo/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';

import 'package:gonullunet_app/services/auth.dart';
import 'package:gonullunet_app/views/login_page.dart';
import 'package:gonullunet_app/views/main_page.dart';

import 'logic/event_cubit.dart';
import 'logic/post_cubit.dart';
import 'logic/user_cubit.dart';
import 'repo/event_repository.dart';
import 'repo/post_repository.dart';
import 'views/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('tr_TR', null);

  final prefs = await SharedPreferences.getInstance();
  final bool showOnboarding = prefs.getBool('showOnboarding') ?? true;

  runApp(MyApp(showOnboarding: showOnboarding));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => PostRepository()),
        RepositoryProvider(create: (context) => EventRepository()),
        RepositoryProvider(create: (context) => UserRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => PostCubit(
              context.read<PostRepository>(),
            )..loadPosts(),
          ),
          BlocProvider(
            create: (context) => EventCubit(context.read<EventRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                EditProfileCubit(context.read<UserRepository>()),
          ),
          BlocProvider(
            create: (context) => UserCubit(
              UserRepository(),
            )..loadUser(),
          ),
        ],
        child: MaterialApp(
          title: 'GönüllüNet',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFF03A9F4)),
            useMaterial3: true,
          ),
          home: showOnboarding ? const OnboardingPage() : const AuthGate(),
        ),
      ),
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const MainPage();
          }
          return const LoginPage();
        });
  }
}
