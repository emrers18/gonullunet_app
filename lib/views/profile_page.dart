import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gonullunet_app/services/auth.dart';
import 'package:gonullunet_app/utils/app_colors.dart'; // Mevcut renkleriniz
import 'package:gonullunet_app/models/user_model.dart';
import '../logic/user_cubit.dart';
import '../logic/user_state.dart';

// Sayfa yönlendirmeleri
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
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Çıkış Yap',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          content: Text('Çıkış yapmak istediğinizden emin misiniz?',
              style: GoogleFonts.plusJakartaSans()),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: <Widget>[
            TextButton(
              child: Text('İptal',
                  style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Çıkış Yap',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.red, fontWeight: FontWeight.bold)),
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
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.kBackgroundColor.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: Text(
          'Profil',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.kTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.kPrimaryColor));
          }

          if (state is UserError) {
            return Center(child: Text(state.message));
          }

          if (state is UserLoaded) {
            final UserModel user = state.user;

            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. PROFIL KARTI ---
                  _buildProfileCard(user),

                  const SizedBox(height: 24),

                  // --- 2. GRUP: HESAP & İŞLEMLER ---
                  _buildSectionTitle("Hesap & İşlemler"),
                  _buildSettingsContainer(
                    children: [
                      _buildSettingsItem(
                        icon: Icons.edit_outlined,
                        iconColor: Colors.blue.shade600,
                        iconBg: Colors.blue.shade50,
                        title: 'Hesap Ayarları',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.notifications_none_rounded,
                        iconColor: AppColors.kPrimaryColor,
                        iconBg: AppColors.kPrimaryColor.withOpacity(0.1),
                        title: 'Bildirimler',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsPage()));
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- 3. GRUP: ETKİNLİKLER (Kullanıcı Tipine Göre) ---
                  if (user.isNgo || user.isVolunteer) ...[
                    _buildSectionTitle("Etkinlikler"),
                    _buildSettingsContainer(
                      children: [
                        if (user.isNgo)
                          _buildSettingsItem(
                            icon: Icons.event_available_rounded,
                            iconColor: Colors.indigo.shade600,
                            iconBg: Colors.indigo.shade50,
                            title: 'Yayınladığım Etkinlikler',
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MyEventsPage()));
                            },
                          ),
                        if (user.isVolunteer)
                          _buildSettingsItem(
                            icon: Icons.check_circle_outline_rounded,
                            iconColor: const Color(0xFF14B8A6),
                            iconBg: const Color(0xFF14B8A6).withOpacity(0.1),
                            title: 'Katıldığım Etkinlikler',
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const JoinedEventsPage()));
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  _buildSectionTitle("Uygulama"),
                  _buildSettingsContainer(
                    children: [
                      _buildSettingsItem(
                        icon: Icons.settings_outlined,
                        iconColor: Colors.purple.shade600,
                        iconBg: Colors.purple.shade50,
                        title: 'Genel Ayarlar',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsPage()));
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.language_rounded,
                        iconColor: Colors.green.shade600,
                        iconBg: Colors.green.shade50,
                        title: 'Dil Seçeneği',
                        onTap: () {
                          // Dil ayarları sayfasına git
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.info_outline_rounded,
                        iconColor: Colors.amber.shade600,
                        iconBg: Colors.amber.shade50,
                        title: 'Hakkında',
                        onTap: () {
                          // Hakkında sayfasına git
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- ÇIKIŞ BUTONU ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showSignOutDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kSurfaceColor,
                        foregroundColor: Colors.red.shade600,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        // Tailwind 'shadow-soft' karşılığı
                        shadowColor: Colors.black.withOpacity(0.05),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Çıkış Yap",
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Versiyon
                  Center(
                    child: Text(
                      "Versiyon 1.0.4",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- WIDGET YARDIMCILARI ---

  Widget _buildProfileCard(UserModel user) {
    return GestureDetector(
      onTap: () {
        if (user.isNgo) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const EditNgoProfilePage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gönüllü profili düzenleme yakında!')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kSurfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1), blurRadius: 5)
                    ],
                    image: (user.imageUrl != null && user.imageUrl!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(user.imageUrl!),
                            fit: BoxFit.cover)
                        : null,
                    color: Colors.grey.shade200,
                  ),
                  child: (user.imageUrl == null || user.imageUrl!.isEmpty)
                      ? Center(
                          child: Text(
                            user.initials,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.kPrimaryColor,
                            ),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.kPrimaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child:
                        const Icon(Icons.edit, size: 10, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // İsim ve Rol
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.isNgo ? "Kurumsal Üye" : "Gönüllü Üye",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kSurfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius:
                      BorderRadius.circular(10), // Yuvarlak kare (Squircle)
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.kTextColor,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
        height: 1, thickness: 1, color: Colors.grey.shade50, indent: 70);
  }
}
