import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
import 'package:gonullunet_app/services/firebase_error_translator.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';
import 'package:gonullunet_app/utils/responsive.dart';

import '../constants/app_constants.dart';
import '../logic/profile_cubit.dart';
import '../logic/profile_state.dart';
import '../repo/user_repository.dart';

class EditVolunteerProfilePage extends StatelessWidget {
  const EditVolunteerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          EditProfileCubit(UserRepository())..loadVolunteerProfileData(),
      child: const _EditVolunteerProfileView(),
    );
  }
}

class _EditVolunteerProfileView extends StatefulWidget {
  const _EditVolunteerProfileView();

  @override
  State<_EditVolunteerProfileView> createState() =>
      _EditVolunteerProfileViewState();
}

class _EditVolunteerProfileViewState extends State<_EditVolunteerProfileView> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _currentImageUrl;
  String _name = '';
  String _surname = '';
  String _email = '';

  List<String> _selectedInterests = [];
  List<String> _selectedSkills = [];
  DateTime? _birthDate;

  bool _initialized = false;

  @override
  void dispose() {
    _bioController.dispose();
    _educationController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
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

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.kPrimaryColor,
            colorScheme: const ColorScheme.light(
              primary: AppColors.kPrimaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.kTextColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  void _onSavePressed(BuildContext context) {
    context.read<EditProfileCubit>().updateVolunteerProfile(
          bio: _bioController.text.trim(),
          interests: _selectedInterests,
          skills: _selectedSkills,
          birthDate: _birthDate,
          education: _educationController.text.trim(),
          city: _cityController.text.trim(),
          phone: _phoneController.text.trim(),
          imageFile: _selectedImage,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).editProfile,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.kTextColor,
            fontWeight: FontWeight.bold,
            fontSize: Responsive.sp(context, 18),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.kTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<EditProfileCubit, EditProfileState>(
        listener: (context, state) {
          if (state is EditProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).profileUpdatedSuccess),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is EditProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(AppMessages.resolve(context, state.message)), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<EditProfileCubit, EditProfileState>(
          builder: (context, state) {
            if (state is EditProfileLoading) {
              return const Center(child: AppLoadingIndicator());
            }

            if (state is EditVolunteerProfileLoaded && !_initialized) {
              _bioController.text = state.bio;
              _educationController.text = state.education;
              _cityController.text = state.city;
              _phoneController.text = state.phone;
              _currentImageUrl = state.imageUrl;
              _name = state.name;
              _surname = state.surname;
              _email = state.email;
              _selectedInterests = List<String>.from(state.interests);
              _selectedSkills = List<String>.from(state.skills);
              if (state.birthDate != null && state.birthDate is Timestamp) {
                _birthDate = (state.birthDate as Timestamp).toDate();
              }
              _initialized = true;
            }

            if (state is EditProfileUpdating) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppLoadingIndicator(),
                    SizedBox(height: Responsive.scale(context, 16)),
                    Text(AppLocalizations.of(context).profileUpdating),
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
                    // --- Uyarı Metni ---
                    Container(
                      padding: Responsive.padding(context, all: 14),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Responsive.scale(context, 12)),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.orange.shade700, size: Responsive.scale(context, 20)),
                          SizedBox(width: Responsive.scale(context, 10)),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).profileVisibilityNote,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: Responsive.sp(context, 13),
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.scale(context, 24)),

                    // --- Profil Resmi ---
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: Responsive.scale(context, 112),
                              height: Responsive.scale(context, 112),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 4),
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
                                              'lib/assets/images/logo.png'),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: Responsive.padding(context, all: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.kPrimaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.kBackgroundColor, width: 2),
                                ),
                                child: Icon(Icons.camera_alt,
                                    color: Colors.white, size: Responsive.scale(context, 16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.scale(context, 8)),
                    Center(
                      child: Text(
                        '$_name $_surname',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: Responsive.sp(context, 18),
                          fontWeight: FontWeight.bold,
                          color: AppColors.kTextColor,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        _email,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: Responsive.sp(context, 13),
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.scale(context, 28)),

                    // --- Hakkımda ---
                    _buildLabel(context, AppLocalizations.of(context).aboutMe),
                    _buildTextArea(
                      context: context,
                      controller: _bioController,
                      hint: AppLocalizations.of(context).aboutMeHint,
                      maxLines: 4,
                    ),
                    SizedBox(height: Responsive.scale(context, 20)),

                    // --- İlgi Alanları ---
                    _buildLabel(context, AppLocalizations.of(context).interests),
                    _buildChipSelector(
                      context: context,
                      available: AppConstants.volunteerInterests,
                      selected: _selectedInterests,
                      onChanged: (list) =>
                          setState(() => _selectedInterests = list),
                    ),
                    SizedBox(height: Responsive.scale(context, 20)),

                    // --- Yetenekler ---
                    _buildLabel(context, AppLocalizations.of(context).skills),
                    _buildChipSelector(
                      context: context,
                      available: AppConstants.volunteerSkills,
                      selected: _selectedSkills,
                      onChanged: (list) =>
                          setState(() => _selectedSkills = list),
                    ),
                    SizedBox(height: Responsive.scale(context, 20)),

                    // --- Doğum Tarihi ---
                    _buildLabel(context, AppLocalizations.of(context).birthDate),
                    GestureDetector(
                      onTap: _selectBirthDate,
                      child: Container(
                        padding: Responsive.padding(context,
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                             Icon(Icons.calendar_today,
                                color: Colors.grey, size: Responsive.scale(context, 20)),
                            SizedBox(width: Responsive.scale(context, 12)),
                            Text(
                              _birthDate != null
                                  ? DateFormat('d MMMM yyyy',
                                          Localizations.localeOf(context)
                                              .toString())
                                      .format(_birthDate!)
                                  : AppLocalizations.of(context)
                                      .selectBirthDate,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: Responsive.sp(context, 16),
                                  color: _birthDate != null
                                      ? AppColors.kTextColor
                                      : Colors.grey,
                                ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.scale(context, 20)),

                    // --- Eğitim Durumu ---
                    _buildLabel(context, AppLocalizations.of(context).educationProfession),
                    _buildInput(
                      context: context,
                      controller: _educationController,
                      hint: AppLocalizations.of(context).educationHint,
                      icon: Icons.school_outlined,
                    ),
                    SizedBox(height: Responsive.scale(context, 20)),

                    // --- Konum ---
                    _buildLabel(context,
                        AppLocalizations.of(context).locationCityDistrict),
                    _buildInput(
                      context: context,
                      controller: _cityController,
                      hint: AppLocalizations.of(context).locationExampleHint,
                      icon: Icons.location_on_outlined,
                    ),
                    SizedBox(height: Responsive.scale(context, 20)),

                    // --- Telefon ---
                    _buildLabel(context, AppLocalizations.of(context).phoneNumber),
                    _buildInput(
                      context: context,
                      controller: _phoneController,
                      hint: "05XX XXX XX XX",
                      icon: Icons.phone_outlined,
                      inputType: TextInputType.phone,
                    ),

                    SizedBox(height: Responsive.scale(context, 32)),

                    // --- Kaydet Butonu ---
                    ElevatedButton(
                      onPressed: () => _onSavePressed(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: Responsive.padding(context, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Responsive.scale(context, 30))),
                          elevation: 4,
                          shadowColor: AppColors.kPrimaryColor.withOpacity(0.3),
                        ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, size: Responsive.scale(context, 22)),
                          SizedBox(width: Responsive.scale(context, 8)),
                          Text(
                            AppLocalizations.of(context).save,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: Responsive.sp(context, 18), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.scale(context, 12)),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                        padding: Responsive.padding(context, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Responsive.scale(context, 30))),
                      ),
                      child: Text(
                        AppLocalizations.of(context).cancel,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(height: Responsive.scale(context, 40)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

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
              ? Icon(icon, color: Colors.grey, size: Responsive.scale(context, 20))
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

  Widget _buildChipSelector({
    required BuildContext context,
    required List<String> available,
    required List<String> selected,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Wrap(
      spacing: Responsive.scale(context, 8),
      runSpacing: Responsive.scale(context, 8),
      children: available.map((item) {
        final isSelected = selected.contains(item);
        return FilterChip(
          label: Text(
            item,
            style: GoogleFonts.plusJakartaSans(
              fontSize: Responsive.sp(context, 13),
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.kTextColor,
            ),
          ),
          selected: isSelected,
          onSelected: (val) {
            final newList = List<String>.from(selected);
            if (val) {
              newList.add(item);
            } else {
              newList.remove(item);
            }
            onChanged(newList);
          },
          selectedColor: AppColors.kPrimaryColor,
          backgroundColor: Colors.white,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.scale(context, 20)),
            side: BorderSide(
              color: isSelected
                  ? AppColors.kPrimaryColor
                  : Colors.grey.shade200,
            ),
          ),
          padding: Responsive.padding(context, horizontal: 4, vertical: 2),
        );
      }).toList(),
    );
  }
}
