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
import 'package:gonullunet_app/utils/responsive.dart';

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
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();

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
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _linkedinController.dispose();
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
          facebookUrl: _facebookController.text.trim(),
          instagramUrl: _instagramController.text.trim(),
          twitterUrl: _twitterController.text.trim(),
          linkedinUrl: _linkedinController.text.trim(),
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
              fontSize: Responsive.sp(context, 18),
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
                  _facebookController.text = state.facebookUrl;
                  _instagramController.text = state.instagramUrl;
                  _twitterController.text = state.twitterUrl;
                  _linkedinController.text = state.linkedinUrl;
                  _currentImageUrl = state.imageUrl;
                }
              }

              if (state is EditProfileUpdating) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppLoadingIndicator(),
                      SizedBox(height: Responsive.scale(context, 16)),
                      Text(AppLocalizations.of(context).profileUpdating,
                          style: GoogleFonts.plusJakartaSans(
                              color: AppColors.kTextColor)),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: Responsive.padding(context,
                      horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.forceComplete) ...[
                        _buildCompleteProfileNotice(context),
                        SizedBox(height: Responsive.scale(context, 24)),
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
                                    width: Responsive.scale(context, 128),
                                    height: Responsive.scale(context, 128),
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
                                      padding:
                                          Responsive.padding(context, all: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.kPrimaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      child: Icon(Icons.edit,
                                          color: Colors.white,
                                          size: Responsive.scale(context, 20)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: Responsive.scale(context, 12)),
                            Text(
                              AppLocalizations.of(context).tapToChangeLogo,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey,
                                fontSize: Responsive.sp(context, 14),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.scale(context, 32)),

                      _buildLabel(context, AppLocalizations.of(context).ngoName),
                      _buildInput(
                          context: context,
                          controller: _stkNameController,
                          hint: ""),

                      SizedBox(height: Responsive.scale(context, 20)),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context,
                                    AppLocalizations.of(context).emailLabel),
                                _buildInput(
                                  context: context,
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
                      SizedBox(height: Responsive.scale(context, 20)),
                      _buildLabel(context, AppLocalizations.of(context).phone),
                      _buildInput(
                          context: context,
                          controller: _phoneController,
                          hint: "",
                          icon: Icons.call,
                          inputType: TextInputType.phone),

                      SizedBox(height: Responsive.scale(context, 20)),
                      _buildLabel(
                          context, AppLocalizations.of(context).location),
                      _buildInput(
                          context: context,
                          controller: _locationController,
                          hint: AppLocalizations.of(context).cityExampleHint,
                          icon: Icons.location_on_outlined),

                      SizedBox(height: Responsive.scale(context, 24)),
                      const Divider(), // default divider uses dividerColor
                      SizedBox(height: Responsive.scale(context, 24)),

                      _buildLabel(context, AppLocalizations.of(context).aboutUs),
                      _buildTextArea(
                          context: context,
                          controller: _descriptionController,
                          hint: AppLocalizations.of(context).ngoDescriptionHint,
                          maxLines: 4),

                      SizedBox(height: Responsive.scale(context, 20)),
                      _buildLabel(
                          context, AppLocalizations.of(context).visionLabel),
                      _buildTextArea(
                          context: context,
                          controller: _visionController,
                          hint: AppLocalizations.of(context).visionHint,
                          maxLines: 3),

                      SizedBox(height: Responsive.scale(context, 20)),
                      _buildLabel(
                          context, AppLocalizations.of(context).missionLabel),
                      _buildTextArea(
                          context: context,
                          controller: _missionController,
                          hint: AppLocalizations.of(context).missionHint,
                          maxLines: 3),

                      SizedBox(height: Responsive.scale(context, 24)),
                      const Divider(),
                      SizedBox(height: Responsive.scale(context, 24)),

                      _buildLabel(
                          context, AppLocalizations.of(context).socialMediaLinks),
                      SizedBox(height: Responsive.scale(context, 12)),
                      _buildLabel(
                          context, AppLocalizations.of(context).facebookLabel),
                      _buildInput(
                        context: context,
                        controller: _facebookController,
                        hint: AppLocalizations.of(context).facebookHint,
                        icon: Icons.facebook_outlined,
                        inputType: TextInputType.url,
                      ),
                      SizedBox(height: Responsive.scale(context, 16)),
                      _buildLabel(
                          context, AppLocalizations.of(context).instagramLabel),
                      _buildInput(
                        context: context,
                        controller: _instagramController,
                        hint: AppLocalizations.of(context).instagramHint,
                        icon: Icons.camera_alt_outlined,
                        inputType: TextInputType.url,
                      ),
                      SizedBox(height: Responsive.scale(context, 16)),
                      _buildLabel(
                          context, AppLocalizations.of(context).twitterLabel),
                      _buildInput(
                        context: context,
                        controller: _twitterController,
                        hint: AppLocalizations.of(context).twitterHint,
                        icon: Icons.alternate_email,
                        inputType: TextInputType.url,
                      ),
                      SizedBox(height: Responsive.scale(context, 16)),
                      _buildLabel(
                          context, AppLocalizations.of(context).linkedinLabel),
                      _buildInput(
                        context: context,
                        controller: _linkedinController,
                        hint: AppLocalizations.of(context).linkedinHint,
                        icon: Icons.business_center_outlined,
                        inputType: TextInputType.url,
                      ),

                      SizedBox(height: Responsive.scale(context, 32)),

                      ElevatedButton(
                        onPressed: () => _onSavePressed(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kPrimaryColor,
                          foregroundColor: Colors.white,
                          padding:
                              Responsive.padding(context, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  Responsive.scale(context, 30))),
                          elevation: 4,
                          shadowColor: AppColors.kPrimaryColor.withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined,
                                size: Responsive.scale(context, 22)),
                            SizedBox(width: Responsive.scale(context, 8)),
                            Text(
                              AppLocalizations.of(context).save,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: Responsive.sp(context, 18),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      if (!widget.forceComplete) ...[
                        SizedBox(height: Responsive.scale(context, 12)),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                            padding:
                                Responsive.padding(context, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    Responsive.scale(context, 30))),
                          ),
                          child: Text(
                            AppLocalizations.of(context).cancel,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: Responsive.sp(context, 16),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                      SizedBox(height: Responsive.scale(context, 40)),
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
      padding: Responsive.padding(context, all: 16),
      decoration: BoxDecoration(
        color: AppColors.kPrimaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
        border: Border.all(color: AppColors.kPrimaryColor.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.kPrimaryColor),
          SizedBox(width: Responsive.scale(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).completeNgoProfileTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.sp(context, 15),
                    color: AppColors.kTextColor,
                  ),
                ),
                SizedBox(height: Responsive.scale(context, 4)),
                Text(
                  AppLocalizations.of(context).completeNgoProfileNotice,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: Responsive.sp(context, 13),
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

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: Responsive.padding(context, left: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.kTextColor,
          fontSize: Responsive.sp(context, 14),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInput({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool readOnly = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: inputType,
        style: GoogleFonts.plusJakartaSans(
          fontSize: Responsive.sp(context, 16),
          color: AppColors.kTextColor,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
            color: Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding:
              Responsive.padding(context, horizontal: 16, vertical: 14),
          prefixIcon: icon != null
              ? Icon(icon,
                  color: Colors.grey, size: Responsive.scale(context, 20))
              : null,
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.plusJakartaSans(
          fontSize: Responsive.sp(context, 16),
          color: AppColors.kTextColor,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
            color: Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding: Responsive.padding(context, all: 16),
        ),
      ),
    );
  }
}
