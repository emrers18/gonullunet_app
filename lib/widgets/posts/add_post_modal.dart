import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/services/auth.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/logic/user_cubit.dart';
import 'package:gonullunet_app/logic/user_state.dart';
import 'package:gonullunet_app/repo/post_repository.dart';
import 'package:gonullunet_app/services/firebase_error_translator.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';
import 'package:gonullunet_app/utils/responsive.dart';

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
  String? _errorMessage;

  bool _isResponsibilityAccepted = false;
  bool _isCommunityRulesAccepted = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _errorMessage = null);
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
      setState(() =>
          _errorMessage = AppLocalizations.of(context).imagePickFailed('$e'));
    }
  }

  void _savePost() async {
    final l10n = AppLocalizations.of(context);
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final user = _auth.currentUser;

    setState(() => _errorMessage = null);

    if (title.isEmpty) {
      setState(() => _errorMessage = l10n.titleEmpty);
      return;
    }
    if (description.isEmpty) {
      setState(() => _errorMessage = l10n.descriptionEmpty);
      return;
    }
    if (user == null) {
      setState(() => _errorMessage = l10n.userSessionNotFound);
      return;
    }

    if (!_isResponsibilityAccepted || !_isCommunityRulesAccepted) {
      setState(() => _errorMessage = l10n.checkAllBoxes);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = context.read<PostRepository>();

      String imageUrl = '';
      if (_selectedImage != null) {
        imageUrl = await repo.uploadImage(_selectedImage!);
        if (imageUrl.isEmpty) {
          throw Exception(l10n.imageUploadFailed);
        }
      }

      await repo.addPost(title, description, imageUrl, user.uid);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).postShared),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = FirebaseErrorTranslator.translate(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    final l10n = AppLocalizations.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(Responsive.scale(context, 32))),
      ),
      padding: EdgeInsets.fromLTRB(
          0, Responsive.scale(context, 12), 0, keyboardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: Responsive.scale(context, 40),
            height: Responsive.scale(context, 4),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(Responsive.scale(context, 2)),
            ),
          ),
          SizedBox(height: Responsive.scale(context, 12)),

          // Header
          Padding(
            padding: Responsive.padding(context, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  l10n.newPost,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: Responsive.sp(context, 17),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                _isSaving
                    ? AppLoadingIndicator(size: Responsive.scale(context, 28))
                    : ElevatedButton(
                        onPressed: _savePost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: Responsive.padding(context,
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                Responsive.scale(context, 20)),
                          ),
                        ),
                        child: Text(
                          l10n.share,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const Divider(),
          if (_errorMessage != null)
            Container(
              padding: Responsive.padding(context, horizontal: 20, vertical: 8),
              color: Colors.red.shade50,
              width: double.infinity,
              child: Text(
                _errorMessage!,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.red.shade700,
                  fontSize: Responsive.sp(context, 13),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: Responsive.padding(context, all: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Section
                  BlocBuilder<UserCubit, UserState>(
                    builder: (context, state) {
                      String displayName = l10n.defaultVolunteerName;
                      String? imageUrl;
                      if (state is UserLoaded) {
                        displayName = state.user.displayName;
                        imageUrl = state.user.imageUrl;
                      }
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: Responsive.scale(context, 20),
                            backgroundColor: AppColors.lightPrimaryColor,
                            backgroundImage:
                                (imageUrl != null && imageUrl.isNotEmpty)
                                    ? CachedNetworkImageProvider(imageUrl)
                                    : null,
                            child: (imageUrl == null || imageUrl.isEmpty)
                                ? Text(displayName[0].toUpperCase())
                                : null,
                          ),
                          SizedBox(width: Responsive.scale(context, 12)),
                          Text(
                            displayName,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.sp(context, 15),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: Responsive.scale(context, 24)),

                  // Title Input
                  TextField(
                    controller: _titleController,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: Responsive.sp(context, 20),
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.addTitle,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                  ),

                  // Description Input
                  TextField(
                    controller: _descriptionController,
                    maxLines: null,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: Responsive.sp(context, 16),
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.whatsHappening,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                  ),

                  SizedBox(height: Responsive.scale(context, 20)),

                  // Image Selection / Preview
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(
                            Responsive.scale(context, 16)),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: _selectedImage != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      Responsive.scale(context, 16)),
                                  child: Image.file(
                                    _selectedImage!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: Responsive.scale(context, 10),
                                  right: Responsive.scale(context, 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImage = null;
                                      });
                                    },
                                    child: Container(
                                      padding:
                                          Responsive.padding(context, all: 4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.close,
                                          color: Colors.white,
                                          size: Responsive.scale(context, 20)),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Padding(
                              padding:
                                  Responsive.padding(context, vertical: 40),
                              child: Column(
                                children: [
                                  Icon(Icons.add_photo_alternate_rounded,
                                      size: Responsive.scale(context, 40),
                                      color: AppColors.primaryColor
                                          .withOpacity(0.5)),
                                  SizedBox(
                                      height: Responsive.scale(context, 8)),
                                  Text(
                                    l10n.addPhoto,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: Responsive.scale(context, 24)),
                  const Divider(),
                  SizedBox(height: Responsive.scale(context, 12)),

                  // Responsibility Checkbox
                  CheckboxListTile(
                    value: _isResponsibilityAccepted,
                    onChanged: (val) => setState(
                        () => _isResponsibilityAccepted = val ?? false),
                    title: Text(
                      l10n.consentAccuracy,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: Responsive.sp(context, 13),
                          color: Colors.grey[700]),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primaryColor,
                    dense: true,
                  ),

                  // Community Rules Checkbox
                  CheckboxListTile(
                    value: _isCommunityRulesAccepted,
                    onChanged: (val) => setState(
                        () => _isCommunityRulesAccepted = val ?? false),
                    title: Text(
                      l10n.consentRules,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: Responsive.sp(context, 13),
                          color: Colors.grey[700]),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primaryColor,
                    dense: true,
                  ),

                  SizedBox(height: Responsive.scale(context, 20)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
