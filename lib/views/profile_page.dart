import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gonullunet_app/models/user_model.dart';
import 'package:gonullunet_app/services/auth.dart';
import 'package:gonullunet_app/utils/app_colors.dart';

import 'edit_ngo_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Auth _auth = Auth();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserModel>? _userStream;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = _auth.currentUser?.uid;

    if (_uid != null) {
      _userStream = _firestore
          .collection('users')
          .doc(_uid!)
          .snapshots()
          .map((snapshot) => UserModel.fromFirestore(snapshot));
    }
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
      body: StreamBuilder<UserModel>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryColor));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Kullanıcı verisi bulunamadı.'));
          }
          final UserModel user = snapshot.data!;

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
                        backgroundImage:
                            (user.imageUrl != null && user.imageUrl!.isNotEmpty)
                                ? NetworkImage(user.imageUrl!)
                                : null,
                        child: (user.imageUrl == null || user.imageUrl!.isEmpty)
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
                          user.isNgo ? 'STK Kullanıcısı' : 'Gönüllü Kullanıcı',
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
                            content: Text('Gönüllü profili düzenleme yakında!'),
                          ),
                        );
                      }
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.notifications_none_outlined,
                    title: 'Bildirimler',
                    onTap: () {},
                  ),
                  if (user.isNgo)
                    _buildProfileOption(
                      icon: Icons.event_available_outlined,
                      title: 'Yayınladığım Etkinlikler',
                      onTap: () {},
                    ),
                  if (user.isVolunteer)
                    _buildProfileOption(
                      icon: Icons.check_circle_outline,
                      title: 'Katıldığım Etkinlikler',
                      onTap: () {},
                    ),
                  _buildProfileOption(
                    icon: Icons.settings_outlined,
                    title: 'Ayarlar',
                    onTap: () {},
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
    // Eğer özel bir renk verilmediyse (Çıkış butonu hariç), Ana Rengi (Mavi) kullan
    final iconColor = color ?? AppColors.kPrimaryColor;
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
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.secondaryText.withOpacity(0.7),
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
