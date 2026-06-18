import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
import 'package:gonullunet_app/logic/user_cubit.dart';
import 'package:gonullunet_app/logic/user_state.dart';
import 'package:gonullunet_app/views/main_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';

class ProfileGate extends StatefulWidget {
  const ProfileGate({super.key});

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  @override
  void initState() {
    super.initState();
    // Profil verisini yüklemeyi başlat
    context.read<UserCubit>().loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserLoaded) {
          return const MainPage();
        }

        if (state is UserError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 64),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context).errorTitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppMessages.resolve(context, state.message),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<UserCubit>().loadUser(),
                      child: Text(AppLocalizations.of(context).retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // UserLoading veya UserInitial
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLoadingIndicator(size: 48),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context).checkingProfile),
              ],
            ),
          ),
        );
      },
    );
  }
}
