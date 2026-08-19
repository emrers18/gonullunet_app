import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
import 'package:gonullunet_app/logic/user_cubit.dart';
import 'package:gonullunet_app/logic/user_state.dart';
import 'package:gonullunet_app/views/main_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';
import 'package:gonullunet_app/utils/responsive.dart';

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
                padding: Responsive.padding(context, all: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red,
                        size: Responsive.scale(context, 64)),
                    SizedBox(height: Responsive.scale(context, 24)),
                    Text(
                      AppLocalizations.of(context).errorTitle,
                      style: GoogleFonts.dmSans(
                        fontSize: Responsive.sp(context, 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: Responsive.scale(context, 8)),
                    Text(
                      AppMessages.resolve(context, state.message),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(color: Colors.grey),
                    ),
                    SizedBox(height: Responsive.scale(context, 24)),
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
                AppLoadingIndicator(size: Responsive.scale(context, 48)),
                SizedBox(height: Responsive.scale(context, 16)),
                Text(AppLocalizations.of(context).checkingProfile),
              ],
            ),
          ),
        );
      },
    );
  }
}
