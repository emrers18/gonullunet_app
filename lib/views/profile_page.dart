import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gonullunet_app/models/user_model.dart';
import 'package:gonullunet_app/services/auth.dart';

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
    // O an giriş yapmış olan kullanıcının UID'sini al
    _uid = _auth.currentUser?.uid;

    if (_uid != null) {
      // Bu UID'ye ait kullanıcının Firestore'daki verisini anlık dinle
      _userStream = _firestore
          .collection('users')
          .doc(_uid!)
          .snapshots()
          .map((snapshot) => UserModel.fromFirestore(snapshot));
    }
  }

  // Çıkış yapmadan önce onay isteyen bir dialog göster
  Future<void> _showSignOutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Dışarı tıklayınca kapanmasın
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
                Navigator.of(dialogContext).pop(); // Dialog'u kapat
              },
            ),
            TextButton(
              child: const Text(
                'Çıkış Yap',
                style: TextStyle(color: Colors.red), // Dikkat çekici
              ),
              onPressed: () async {
                // Önce Auth servisinden çıkış yap
                await _auth.signOut();

                // Dialog'u kapat
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }

                // (AuthGate bizi otomatik olarak LoginPage'e yönlendirecek)
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Renkleri tanımlayalım (veya AppColors'tan çekelim)
    const Color primaryColor = Color(0xFFFF5722); // Ana turuncu renk
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
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      // Kullanıcı verisini dinleyen StreamBuilder
      body: StreamBuilder<UserModel>(
        stream: _userStream,
        builder: (context, snapshot) {
          // 1. Veri bekleniyor
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: primaryColor));
          }

          // 2. Hata oluştu
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          // 3. Veri yok veya kullanıcı dökümanı bulunamadı
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Kullanıcı verisi bulunamadı.'));
          }

          // 4. Veri başarıyla alındı!
          final UserModel user = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Profil Başlığı ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        child: Text(
                          user.initials,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Chip(
                        label: Text(
                          user.isNgo ? 'STK Kullanıcısı' : 'Gönüllü Kullanıcı',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Divider(),

                  // --- Profil Seçenekleri ---
                  _buildProfileOption(
                    icon: Icons.edit_outlined,
                    title: 'Profili Düzenle',
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.notifications_none_outlined,
                    title: 'Bildirimler',
                    onTap: () {},
                  ),

                  // STK'lara özel seçenek
                  if (user.isNgo)
                    _buildProfileOption(
                      icon: Icons.event_available_outlined,
                      title: 'Yayınladığım Etkinlikler',
                      onTap: () {},
                    ),

                  // Gönüllülere özel seçenek
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

                  // --- Çıkış Yap Butonu ---
                  _buildProfileOption(
                    icon: Icons.logout,
                    title: 'Çıkış Yap',
                    color: Colors.red, // Kırmızı renk
                    onTap: () {
                      // Çıkış yapmadan önce onayla
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
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: color.withOpacity(0.7),
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
