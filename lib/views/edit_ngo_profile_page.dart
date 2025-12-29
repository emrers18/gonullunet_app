import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/widgets/custom_input_field.dart';

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
  late TextEditingController _stkNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _stkNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _stkNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
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
      // ignore: use_build_context_synchronously
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
          imageFile: _selectedImage,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        title: const Text('Kurum Profilini Düzenle'),
        centerTitle: true,
        backgroundColor: AppColors.kBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
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
              }
              if (_descriptionController.text.isEmpty) {
                _descriptionController.text = state.description;
              }
              if (_locationController.text.isEmpty) {
                _locationController.text = state.location;
              }
              _currentImageUrl ??= state.imageUrl;
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!) as ImageProvider
                                  : (_currentImageUrl != null &&
                                          _currentImageUrl!.isNotEmpty)
                                      ? NetworkImage(_currentImageUrl!)
                                      : null,
                              child: (_selectedImage == null &&
                                      (_currentImageUrl == null ||
                                          _currentImageUrl!.isEmpty))
                                  ? const Icon(Icons.add_a_photo,
                                      size: 40, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fotoğrafı Değiştir',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Kurum Bilgileri',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bu bilgiler "Kurumlar" sayfasında diğer kullanıcılara gösterilecektir.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    CustomInputField(
                      controller: _stkNameController,
                      hintText: 'STK Adı',
                    ),
                    const SizedBox(height: 16),
                    CustomInputField(
                      controller: _descriptionController,
                      hintText: 'Açıklama (Kurumunuzun amacı, misyonu vb.)',
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 16),
                    CustomInputField(
                      controller: _locationController,
                      hintText: 'Konum (Örn: İstanbul, Türkiye)',
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => _onSavePressed(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Kaydet',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
