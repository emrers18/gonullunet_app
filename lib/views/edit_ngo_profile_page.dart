import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gonullunet_app/services/firebase_error_translator.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';

import '../logic/profile_cubit.dart';
import '../logic/profile_state.dart';
import '../repo/user_repository.dart';

class EditNgoProfilePage extends StatelessWidget {
  /// true ise: kayıt sonrası profil tamamlanana kadar gösterilen zorunlu mod.
  /// Geri butonu, iptal butonu yoktur; tüm alanlar doldurulmadan kaydedilemez.
  final bool forceComplete;

  const EditNgoProfilePage({super.key, this.forceComplete = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          EditProfileCubit(UserRepository())..loadProfileData(),
      child: EditNgoProfileView(forceComplete: forceComplete),
    );
  }
}

class EditNgoProfileView extends StatefulWidget {
  final bool forceComplete;

  const EditNgoProfileView({super.key, this.forceComplete = false});

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(FirebaseErrorTranslator.translate(e))),
        );
      }
    }
  }

  void _onSavePressed(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_stkNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ngoNameEmptyError)),
      );
      return;
    }

    // Zorunlu tamamlama modunda tüm alanlar doldurulmadan kaydedilemez;
    // aksi halde AuthGate profili yine eksik görüp bu sayfayı tekrar açar.
    if (widget.forceComplete) {
      if (_descriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.descriptionEmpty)));
        return;
      }
      if (_locationController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.locationEmptyError)));
        return;
      }
      if (_phoneController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.phoneEmptyError)));
        return;
      }
      if (_visionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.visionEmptyError)));
        return;
      }
      if (_missionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.missionEmptyError)));
        return;
      }
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
    return PopScope(
      canPop: !widget.forceComplete,
      child: Scaffold(
        backgroundColor: AppColors.kBackgroundColor,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).editNgoProfile,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.kTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: !widget.forceComplete,
          leading: widget.forceComplete
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: AppColors.kTextColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.grey.shade200, height: 1.0),
          ),
        ),
        body: BlocListener<EditProfileCubit, EditProfileState>(
          listener: (context, state) {
            if (state is EditProfileSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(AppLocalizations.of(context).profileUpdatedSuccess),
                  backgroundColor: Colors.green,
                ),
              );
              // Zorunlu modda kapatılacak önceki bir sayfa yok — AuthGate,
              // Firestore güncellemesini algılayıp otomatik olarak MainPage'e geçer.
              if (!widget.forceComplete) {
                Navigator.pop(context);
              }
            } else if (state is EditProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(AppMessages.resolve(context, state.message)),
                    backgroundColor: Colors.red),
              );
            }
          },
          child: BlocBuilder<EditProfileCubit, EditProfileState>(
            builder: (context, state) {
              if (state is EditProfileLoading) {
                return const Center(child: AppLoadingIndicator());
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppLoadingIndicator(),
                      const SizedBox(height: 16),
                      Text(AppLocalizations.of(context).profileUpdating,
                          style: GoogleFonts.plusJakartaSans(
                              color: AppColors.kTextColor)),
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
                      if (widget.forceComplete) ...[
                        _buildCompleteProfileNotice(context),
                        const SizedBox(height: 24),
                      ],
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
                                                    _currentImageUrl!
                                                        .isNotEmpty)
                                                ? NetworkImage(
                                                        _currentImageUrl!)
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
                                        color: AppColors.kPrimaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
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
                              AppLocalizations.of(context).tapToChangeLogo,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildLabel(AppLocalizations.of(context).ngoName),
                      _buildInput(controller: _stkNameController, hint: ""),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(
                                    AppLocalizations.of(context).emailLabel),
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
                      _buildLabel(AppLocalizations.of(context).phone),
                      _buildInput(
                          controller: _phoneController,
                          hint: "",
                          icon: Icons.call,
                          inputType: TextInputType.phone),

                      const SizedBox(height: 20),
                      _buildLabel(AppLocalizations.of(context).location),
                      _buildInput(
                          controller: _locationController,
                          hint: AppLocalizations.of(context).cityExampleHint,
                          icon: Icons.location_on_outlined),

                      const SizedBox(height: 24),
                      const Divider(), // default divider uses dividerColor
                      const SizedBox(height: 24),

                      _buildLabel(AppLocalizations.of(context).aboutUs),
                      _buildTextArea(
                          controller: _descriptionController,
                          hint: AppLocalizations.of(context).ngoDescriptionHint,
                          maxLines: 4),

                      const SizedBox(height: 20),
                      _buildLabel(AppLocalizations.of(context).visionLabel),
                      _buildTextArea(
                          controller: _visionController,
                          hint: AppLocalizations.of(context).visionHint,
                          maxLines: 3),

                      const SizedBox(height: 20),
                      _buildLabel(AppLocalizations.of(context).missionLabel),
                      _buildTextArea(
                          controller: _missionController,
                          hint: AppLocalizations.of(context).missionHint,
                          maxLines: 3),

                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: () => _onSavePressed(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 4,
                          shadowColor: AppColors.kPrimaryColor.withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save_outlined, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context).save,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      if (!widget.forceComplete) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            AppLocalizations.of(context).cancel,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteProfileNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kPrimaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kPrimaryColor.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.kPrimaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).completeNgoProfileTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.kTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).completeNgoProfileNotice,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.kTextColor.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.kTextColor,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: inputType,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          color: AppColors.kTextColor,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
            color: Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          color: AppColors.kTextColor,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
            color: Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
