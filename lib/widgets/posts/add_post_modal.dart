// lib/widgets/posts/add_post_modal.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gonullunet_app/services/auth.dart'; // Auth servisi
import 'package:gonullunet_app/utils/app_colors.dart'; // Renklerin
import 'package:gonullunet_app/widgets/custom_input_field.dart'; // Özel input alanımız

class AddPostModal extends StatefulWidget {
  const AddPostModal({super.key});

  @override
  State<AddPostModal> createState() => _AddPostModalState();
}

class _AddPostModalState extends State<AddPostModal> {
  // Controller'lar
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  // Servisler
  final Auth _auth = Auth();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _savePost() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final user = _auth.currentUser;

    // Doğrulama
    if (title.isEmpty) {
      _showError('Başlık boş bırakılamaz.');
      return;
    }
    if (description.isEmpty) {
      _showError('Açıklama boş bırakılamaz.');
      return;
    }
    if (user == null) {
      _showError('Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.');
      return;
    }

    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    try {
      // 'posts' koleksiyonuna yeni bir belge ekle
      await _firestore.collection('posts').add({
        'title': title,
        'description': description,
        'imageUrl': imageUrl, // (Boşsa, model 'placeholder'a çevirecek)
        'publisherId': user.uid, // Gönderiyi yayınlayan STK'nın UID'si
        'createdAt': Timestamp.now(), // Sıralama için şimdiki zaman
        'likeCount': 0,
        'commentCount': 0,
      });

      // Başarılıysa modal'ı kapat
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Gönderi kaydedilemedi: $e');
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
    // Klavyenin kapladığı alanı hesaba katmak için
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      // Modal'ı klavyenin üzerine çıkarmak için
      padding: EdgeInsets.only(bottom: keyboardPadding),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: AppColors.kCardBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // "Çekme Çubuğu" (İsteğe bağlı)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Yeni Gönderi Oluştur',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              CustomInputField(
                controller: _titleController,
                hintText: 'Başlık',
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _descriptionController,
                hintText: 'Açıklama...',
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _imageUrlController,
                hintText: 'Görsel URL\'si (İsteğe bağlı)',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _savePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kPrimaryColor,
                  foregroundColor: Colors.white,
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
                        'Paylaş',
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
