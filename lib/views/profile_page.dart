import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gonullunet_app/services/auth.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/models/user_model.dart';
import '../logic/user_cubit.dart';
import '../logic/user_state.dart';
import 'edit_ngo_profile_page.dart';
import 'notifications_page.dart';
import 'my_events_page.dart';
import 'joined_events_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Auth _auth = Auth();

  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().loadUser();
  }

  Future<void> _showSignOutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Çıkış yapmak istediğinizden emin misiniz?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Çıkış Yap',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await _auth.signOut();
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFF9F9F9);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profilim',
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryColor));
          }

          if (state is UserError) {
            return Center(child: Text(state.message));
          }

          if (state is UserLoaded) {
            final UserModel user = state.user;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.lightPrimaryColor,
                          backgroundImage: (user.imageUrl != null &&
                                  user.imageUrl!.isNotEmpty)
                              ? NetworkImage(user.imageUrl!)
                              : null,
                          child:
                              (user.imageUrl == null || user.imageUrl!.isEmpty)
                                  ? Text(
                                      user.initials,
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkPrimaryColor,
                                      ),
                                    )
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.displayName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Chip(
                          label: Text(
                            user.isNgo
                                ? 'STK Kullanıcısı'
                                : 'Gönüllü Kullanıcı',
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.black12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    _buildProfileOption(
                      icon: Icons.edit_outlined,
                      title: 'Profili Düzenle',
                      onTap: () {
                        if (user.isNgo) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditNgoProfilePage(),
                            ),
                          );
                        } else if (user.isVolunteer) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Gönüllü profili düzenleme yakında!'),
                            ),
                          );
                        }
                      },
                    ),
                    _buildProfileOption(
                      icon: Icons.notifications_none_outlined,
                      title: 'Bildirimler',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsPage(),
                          ),
                        );
                      },
                    ),
                    if (user.isNgo)
                      _buildProfileOption(
                        icon: Icons.event_available_outlined,
                        title: 'Yayınladığım Etkinlikler',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyEventsPage(),
                            ),
                          );
                        },
                      ),
                    if (user.isVolunteer)
                      _buildProfileOption(
                        icon: Icons.check_circle_outline,
                        title: 'Katıldığım Etkinlikler',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const JoinedEventsPage(),
                            ),
                          );
                        },
                      ),
                    _buildProfileOption(
                      icon: Icons.settings_outlined,
                      title: 'Ayarlar',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildProfileOption(
                      icon: Icons.logout,
                      title: 'Çıkış Yap',
                      color: Colors.red,
                      onTap: () {
                        _showSignOutDialog();
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final iconColor = color ?? AppColors.primaryColor;
    final textColor = color ?? AppColors.primaryText;

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppColors.secondaryText,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
