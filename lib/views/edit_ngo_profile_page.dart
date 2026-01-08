import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gonullunet_app/utils/app_colors.dart';

import '../logic/profile_cubit.dart';
import '../logic/profile_state.dart';
import '../repo/user_repository.dart';

class EditNgoProfilePage extends StatelessWidget {
  const EditNgoProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          EditProfileCubit(UserRepository())..loadProfileData(),
      child: const EditNgoProfileView(),
    );
  }
}

class EditNgoProfileView extends StatefulWidget {
  const EditNgoProfileView({super.key});

  @override
  State<EditNgoProfileView> createState() => _EditNgoProfileViewState();
}

class _EditNgoProfileViewState extends State<EditNgoProfileView> {
  final TextEditingController _stkNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _visionController = TextEditingController();
  final TextEditingController _missionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _currentImageUrl;

  @override
  void dispose() {
    _stkNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _visionController.dispose();
    _missionController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Resim seçilemedi: $e")),
      );
    }
  }

  void _onSavePressed(BuildContext context) {
    if (_stkNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("STK Adı boş olamaz.")),
      );
      return;
    }

    context.read<EditProfileCubit>().updateProfile(
          stkName: _stkNameController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          phone: _phoneController.text.trim(),
          vision: _visionController.text.trim(),
          mission: _missionController.text.trim(),
          imageFile: _selectedImage,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F5), // background-light
      appBar: AppBar(
        title: Text(
          'STK Profilini Düzenle',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF181210), // text-main
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F6F5).withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF181210)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.transparent, height: 1.0),
        ),
      ),
      body: BlocListener<EditProfileCubit, EditProfileState>(
        listener: (context, state) {
          if (state is EditProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil başarıyla güncellendi!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is EditProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<EditProfileCubit, EditProfileState>(
          builder: (context, state) {
            if (state is EditProfileLoading) {
              return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryColor));
            }

            if (state is EditProfileLoaded) {
              if (_stkNameController.text.isEmpty) {
                _stkNameController.text = state.stkName;
                _emailController.text = state.email;
                _phoneController.text = state.phone;
                _locationController.text = state.location;
                _descriptionController.text = state.description;
                _visionController.text = state.vision;
                _missionController.text = state.mission;
                _currentImageUrl = state.imageUrl;
              }
            }

            if (state is EditProfileUpdating) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryColor),
                    SizedBox(height: 16),
                    Text("Profil güncelleniyor..."),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Profil Resmi Alanı ---
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 128,
                                  height: 128,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: _selectedImage != null
                                          ? FileImage(_selectedImage!)
                                          : (_currentImageUrl != null &&
                                                  _currentImageUrl!.isNotEmpty)
                                              ? NetworkImage(_currentImageUrl!)
                                                  as ImageProvider
                                              : const AssetImage(
                                                  'lib/assets/images/logo.png'), // Varsayılan görsel
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: const Color(0xFFF8F6F5),
                                          width: 2),
                                    ),
                                    child: const Icon(Icons.edit,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Logoyu değiştirmek için dokunun',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF8D6A5E), // text-muted
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- Form Alanları ---
                    _buildLabel("STK Adı"),
                    _buildInput(controller: _stkNameController, hint: ""),

                    const SizedBox(height: 20),

                    // İletişim Grubu
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("E-posta"),
                              _buildInput(
                                controller: _emailController,
                                hint: "",
                                icon: Icons.mail_outline,
                                readOnly: true, // E-posta genelde değişmez
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildLabel("Telefon"),
                    _buildInput(
                        controller: _phoneController,
                        hint: "",
                        icon: Icons.call,
                        inputType: TextInputType.phone),

                    const SizedBox(height: 20),
                    _buildLabel("Konum"),
                    _buildInput(
                        controller: _locationController,
                        hint: "Kadıköy, İstanbul",
                        icon: Icons.location_on_outlined),

                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFE7DEDA)), // border-light
                    const SizedBox(height: 24),

                    _buildLabel("Hakkımızda"),
                    _buildTextArea(
                        controller: _descriptionController,
                        hint: "Kuruluşunuz hakkında kısa bir açıklama yazın...",
                        maxLines: 4),

                    const SizedBox(height: 20),
                    _buildLabel("Vizyon"),
                    _buildTextArea(
                        controller: _visionController,
                        hint: "Vizyonunuz...",
                        maxLines: 3),

                    const SizedBox(height: 20),
                    _buildLabel("Misyon"),
                    _buildTextArea(
                        controller: _missionController,
                        hint: "Misyonunuz...",
                        maxLines: 3),

                    const SizedBox(height: 32),

                    // --- Aksiyon Butonları ---
                    ElevatedButton(
                      onPressed: () => _onSavePressed(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 4,
                        shadowColor: AppColors.primaryColor.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_outlined, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Kaydet',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF8D6A5E), // text-muted
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        'İptal',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 40), // Alt boşluk
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Yardımcı Widgetlar ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF181210),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool readOnly = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // surface-light
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7DEDA)), // border-light
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: inputType,
        style: GoogleFonts.plusJakartaSans(
            fontSize: 16, color: const Color(0xFF181210)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.plusJakartaSans(color: const Color(0xFF8D6A5E)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: icon != null
              ? Icon(icon, color: const Color(0xFF8D6A5E), size: 20)
              : null,
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7DEDA)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.plusJakartaSans(
            fontSize: 16, color: const Color(0xFF181210)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.plusJakartaSans(color: const Color(0xFF8D6A5E)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
