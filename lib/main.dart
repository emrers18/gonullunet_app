import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gonullunet_app/logic/chat_cubit/chat_cubit.dart';
import 'package:gonullunet_app/logic/profile_cubit.dart';
import 'package:gonullunet_app/repo/chat_repository.dart';
import 'package:gonullunet_app/repo/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';

import 'logic/event_cubit.dart';
import 'logic/post_cubit.dart';
import 'logic/user_cubit.dart';
import 'repo/event_repository.dart';
import 'repo/post_repository.dart';
import 'views/auth_gate.dart';
import 'views/onboarding_page.dart';
import 'services/notification_service.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
  //     overlays: [SystemUiOverlay.top]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('tr_TR', null);
  await NotificationService().initialize();

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
        RepositoryProvider(create: (context) => ChatRepository()),
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
          BlocProvider(
            create: (context) => ChatCubit(
              context.read<ChatRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'GönüllüNet',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppColors.kPrimaryColor,
            scaffoldBackgroundColor: AppColors.kBackgroundColor,
            useMaterial3: true,
            fontFamily: 'Inter',
          ),
          home: showOnboarding ? const OnboardingPage() : const AuthGate(),
        ),
      ),
    );
  }
}
