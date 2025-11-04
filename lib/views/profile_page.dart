import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gonullunet_app/services/auth.dart'; // Auth servisimizi import ediyoruz
// import 'package:gonullunet_app/utils/app_colors.dart'; // Varsa renk paletinizi ekleyin

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Auth _auth = Auth();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;
  String? _uid;

  @override
  void initState() {
    super.initState();
    // O an giriş yapmış olan kullanıcının UID'sini al
    _uid = _auth.currentUser?.uid;

    if (_uid != null) {
      // Bu UID'ye ait kullanıcının Firestore'daki verisini anlık dinle
      _userStream = _firestore.collection('users').doc(_uid!).snapshots();
    }
  }

  // Kullanıcının baş harflerini almak için yardımcı bir fonksiyon
  String _getInitials(String name, [String surname = '']) {
    if (name.isEmpty) return '?';

    // Eğer STK ise (soyad boş gelirse)
    if (surname.isEmpty) {
      var parts = name.split(' ');
      if (parts.length > 1) {
        return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
      } else {
        return name[0].toUpperCase();
      }
    }

    // Gönüllü ise
    return name[0].toUpperCase() + surname[0].toUpperCase();
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Kullanıcı verisi bulunamadı.'));
          }

          // 4. Veri başarıyla alındı!
          final userData = snapshot.data!.data()!;
          final userType = userData['userType'] ?? 'volunteer';
          final email = userData['email'] ?? 'E-posta yok';

          String displayName, initials;

          if (userType == 'ngo') {
            displayName = userData['stkName'] ?? 'STK Adı Yok';
            initials = _getInitials(displayName);
          } else {
            displayName =
                '${userData['name'] ?? ''} ${userData['surname'] ?? ''}';
            initials =
                _getInitials(userData['name'] ?? '', userData['surname'] ?? '');
          }

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
                          initials,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Chip(
                        label: Text(
                          userType == 'ngo' ? 'STK Hesabı' : 'Gönüllü',
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
                    onTap: () {
                      // TODO: Profil düzenleme sayfasına git
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.notifications_none_outlined,
                    title: 'Bildirimler',
                    onTap: () {
                      // TODO: Bildirimler sayfasına git
                    },
                  ),

                  // STK'lara özel seçenek
                  if (userType == 'ngo')
                    _buildProfileOption(
                      icon: Icons.event_available_outlined,
                      title: 'Yayınladığım Etkinlikler',
                      onTap: () {
                        // TODO: STK'nın kendi etkinliklerini gördüğü sayfaya git
                      },
                    ),

                  // Gönüllülere özel seçenek
                  if (userType == 'volunteer')
                    _buildProfileOption(
                      icon: Icons.check_circle_outline,
                      title: 'Katıldığım Etkinlikler',
                      onTap: () {
                        // TODO: Gönüllünün katıldığı etkinlikleri gördüğü sayfaya git
                      },
                    ),

                  _buildProfileOption(
                    icon: Icons.settings_outlined,
                    title: 'Ayarlar',
                    onTap: () {
                      // TODO: Ayarlar sayfasına git
                    },
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

  // Seçenekler için yardımcı bir widget
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black87, // Varsayılan renk
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
