import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gonullunet_app/services/auth.dart';
import 'package:gonullunet_app/utils/app_colors.dart';

import '../../logic/post_cubit.dart';

class AddPostModal extends StatefulWidget {
  const AddPostModal({super.key});

  @override
  State<AddPostModal> createState() => _AddPostModalState();
}

class _AddPostModalState extends State<AddPostModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();
  final Auth _auth = Auth();

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Resim seçilemedi: $e")),
        );
      }
    }
  }

  void _savePost() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final user = _auth.currentUser;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlık boş bırakılamaz.')),
      );
      return;
    }
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Açıklama boş bırakılamaz.')),
      );
      return;
    }
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı oturumu bulunamadı.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await context.read<PostCubit>().addPostWithImage(
          title,
          description,
          _selectedImage,
          user.uid,
        );

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("İşlem tamamlandı."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Ortak Input Dekorasyonu (Modern Stil)
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      floatingLabelStyle: const TextStyle(color: AppColors.primaryColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white, // input-bg-light
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // rounded-xl
        borderSide: BorderSide(
            color: Colors.grey.shade300), // border-input-border-light
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Klavye açıldığında padding
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // Modal arka planı
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + keyboardPadding),
      decoration: const BoxDecoration(
        color: Colors.white, // bg-modal-light
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)), // rounded-t-3xl
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SÜRÜKLEME ÇUBUĞU (DRAG HANDLE) ---
            Center(
              child: Container(
                width: 48, // w-12
                height: 6, // h-1.5
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3), // rounded-full
                ),
              ),
            ),

            // --- BAŞLIK ---
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Yeni Gönderi Oluştur',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20, // text-xl
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827), // text-gray-900
                  letterSpacing: -0.5, // tracking-tight
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- RESİM SEÇME ALANI (Dashed Border Görünümü) ---
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 192, // h-48
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB), // bg-gray-50
                  borderRadius: BorderRadius.circular(16), // rounded-2xl
                  border: Border.all(
                    color: Colors.grey.shade300, // border-gray-200
                    width: 2,
                    // Not: Flutter'da yerleşik "dashed" border yok,
                    // dotted_border paketi olmadan solid kullanıyoruz ama stilini benzetiyoruz.
                  ),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Fotoğraf Ekle (İsteğe Bağlı)",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          // Resmi kaldırma butonu
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                    )
                                  ],
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // --- BAŞLIK INPUT ---
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Color(0xFF111827), fontSize: 16),
              decoration: _buildInputDecoration("Başlık"),
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            // --- AÇIKLAMA INPUT ---
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Color(0xFF111827), fontSize: 16),
              maxLines: 4, // rows="3" karşılığı yaklaşık
              decoration: _buildInputDecoration("Açıklama..."),
            ),

            const SizedBox(height: 24), // pt-2 + spacing

            // --- PAYLAŞ BUTONU ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _savePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor, // bg-primary
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor:
                      AppColors.primaryColor.withOpacity(0.3), // shadow-lg
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // rounded-2xl
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Paylaş',
                        style: TextStyle(
                          fontSize: 18, // text-lg
                          fontWeight: FontWeight.w600, // font-semibold
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // --- ALT DEKORATİF ÇİZGİ ---
            Center(
              child: Container(
                width: 128, // w-32
                height: 4, // h-1
                decoration: BoxDecoration(
                  color: Colors.grey[200], // bg-gray-900/10
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
