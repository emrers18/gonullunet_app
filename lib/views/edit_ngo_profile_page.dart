import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gonullunet_app/services/auth.dart';
import 'package:gonullunet_app/widgets/custom_input_field.dart';
import 'package:gonullunet_app/utils/app_colors.dart';

class EditNgoProfilePage extends StatefulWidget {
  const EditNgoProfilePage({super.key});

  @override
  State<EditNgoProfilePage> createState() => _EditNgoProfilePageState();
}

class _EditNgoProfilePageState extends State<EditNgoProfilePage> {
  // Firebase Servisleri
  final Auth _auth = Auth();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controller'lar
  late TextEditingController _stkNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _imageUrlController;

  // Yüklenme Durumları
  bool _isLoadingPage = true; // Sayfa ilk açılırken veriyi çekmek için
  bool _isSaving = false; // Kayıt butonuna basıldığında

  @override
  void initState() {
    super.initState();
    // Controller'ları başlat
    _stkNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _imageUrlController = TextEditingController();

    // Mevcut verileri Firestore'dan yükle
    _loadCurrentNgoData();
  }

  @override
  void dispose() {
    // Controller'ları temizle
    _stkNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Sayfa açıldığında STK'nın mevcut verilerini yükler
  Future<void> _loadCurrentNgoData() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoadingPage = false;
        });
        _showError("Kullanıcı bulunamadı. Lütfen tekrar giriş yapın.");
      }
      return;
    }

    try {
      // Kullanıcının belgesini Firestore'dan bir kerelik al
      final docSnapshot =
          await _firestore.collection('users').doc(user.uid).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;

        // Controller'lara mevcut verileri doldur
        if (mounted) {
          setState(() {
            _stkNameController.text = data['stkName'] ?? '';
            _descriptionController.text = data['description'] ?? '';
            _locationController.text = data['location'] ?? '';
            _imageUrlController.text = data['imageUrl'] ?? '';
          });
        }
      }
    } catch (e) {
      _showError("Veriler yüklenirken bir hata oluştu: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPage = false;
        });
      }
    }
  }

  // Hata göstermek için
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentColor, // veya Colors.red
      ),
    );
  }

  // Kaydetme fonksiyonu (senin sağladığın fonksiyonun geliştirilmiş hali)
  Future<void> _saveNgoProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      _showError("Kullanıcı oturumu bulunamadı.");
      return;
    }

    // Basit validasyon
    if (_stkNameController.text.trim().isEmpty) {
      _showError("STK Adı boş bırakılamaz.");
      return;
    }

    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    try {
      // Firestore'da kullanıcının belgesini GÜNCELLE
      await _firestore.collection('users').doc(user.uid).update({
        'stkName': _stkNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        // 'profileCompleted': true // (İsteğe bağlı)
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil başarıyla güncellendi!'),
            backgroundColor: Colors.green, // Başarı rengi
          ),
        );
        // Başarılı olunca bir önceki sayfaya (Profilim) geri dön
        Navigator.pop(context);
      }
    } catch (e) {
      _showError("Profil güncellenemedi: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        title: const Text('STK Profilini Düzenle'),
        centerTitle: true,
        backgroundColor: AppColors.kBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoadingPage
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Kurum Bilgileri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bu bilgiler "Kurumlar" sayfasında diğer kullanıcılara gösterilecektir.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // STK Adı
                    CustomInputField(
                      controller: _stkNameController,
                      hintText: 'STK Adı',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),

                    // Açıklama
                    CustomInputField(
                      controller: _descriptionController,
                      hintText: 'Açıklama (Kurumunuzun amacı, misyonu vb.)',
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 16),

                    // Konum
                    CustomInputField(
                      controller: _locationController,
                      hintText: 'Konum (Örn: İstanbul, Türkiye)',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),

                    // Resim URL'si
                    CustomInputField(
                      controller: _imageUrlController,
                      hintText: 'Profil Resmi URL\'si',
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 32),

                    // Kaydet Butonu
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveNgoProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentColor,
                        foregroundColor: AppColors.textColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'Kaydet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
