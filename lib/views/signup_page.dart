import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/utils/validators/validators.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';

import '../logic/signup_cubit.dart';
import '../logic/signup_state.dart';
import 'email_verification_screen.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpCubit(),
      child: const SignUpView(),
    );
  }
}

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  // 0: Gönüllü, 1: STK
  int _selectedIndex = 0;
  bool _isPasswordVisible = false;

  final TextEditingController _volNameController = TextEditingController();
  final TextEditingController _volSurnameController = TextEditingController();
  final TextEditingController _volEmailController = TextEditingController();
  final TextEditingController _volPasswordController = TextEditingController();

  final TextEditingController _stkNameController = TextEditingController();
  final TextEditingController _stkEmailController = TextEditingController();
  final TextEditingController _stkPasswordController = TextEditingController();

  @override
  void dispose() {
    _volNameController.dispose();
    _volSurnameController.dispose();
    _volEmailController.dispose();
    _volPasswordController.dispose();
    _stkNameController.dispose();
    _stkEmailController.dispose();
    _stkPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onSignUpPressed(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String name = '', surname = '', email = '', password = '', userType = '';
    String? stkName;

    if (_selectedIndex == 1) {
      // STK
      stkName = _stkNameController.text.trim();
      email = _stkEmailController.text.trim();
      password = _stkPasswordController.text;
      userType = 'ngo';

      if (stkName.isEmpty) return _showError(l10n.ngoNameEmpty);
    } else {
      // Gönüllü
      name = _volNameController.text.trim();
      surname = _volSurnameController.text.trim();
      email = _volEmailController.text.trim();
      password = _volPasswordController.text;
      userType = 'volunteer';

      if (name.isEmpty) return _showError(l10n.nameEmpty);
      if (surname.isEmpty) return _showError(l10n.surnameEmpty);
    }

    if (email.isEmpty) return _showError(l10n.emailEmpty);
    if (!AppValidators.emailReg.hasMatch(email)) {
      return _showError(l10n.invalidEmail);
    }
    if (password.isEmpty) return _showError(l10n.passwordEmpty);
    if (!AppValidators.passwordReg.hasMatch(password)) {
      return _showError(l10n.passwordWeak);
    }

    context.read<SignUpCubit>().signUp(
          email: email,
          password: password,
          userType: userType,
          name: name,
          surname: surname,
          stkName: stkName,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      body: BlocListener<SignUpCubit, SignUpState>(
        listener: (context, state) {
          if (state is SignUpSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) =>
                    EmailVerificationScreen(email: state.email),
              ),
              (route) => false,
            );
          } else if (state is SignUpError) {
            _showError(AppMessages.resolve(context, state.message));
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.kTextColor),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Logo Alanı (Gradient ve Dönme Efekti)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.kPrimaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(),
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: -0.05,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.kPrimaryColor,
                              Colors.orangeAccent
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.kPrimaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.volunteer_activism,
                            color: Colors.white, size: 32),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  "GönüllüNet",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kPrimaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  _selectedIndex == 0
                      ? l10n.signupVolunteerTagline
                      : l10n.signupNgoTagline,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(height: 32),

                // --- 2. TOGGLE (Gönüllü / STK Seçimi) ---
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildToggleButton(
                          text: l10n.roleVolunteer,
                          icon: Icons.person_outline,
                          isSelected: _selectedIndex == 0,
                          activeColor: AppColors.darkPrimaryColor,
                          onTap: () => setState(() => _selectedIndex = 0),
                        ),
                      ),
                      Expanded(
                        child: _buildToggleButton(
                          text: l10n.roleNgo,
                          icon: Icons.business_outlined, // corporate_fare
                          isSelected: _selectedIndex == 1,
                          activeColor: AppColors.darkPrimaryColor,
                          onTap: () => setState(() => _selectedIndex = 1),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- 3. FORM ALANI ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.createAccount,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedIndex == 0
                            ? l10n.signupVolunteerSubtitle
                            : l10n.signupNgoSubtitle,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (_selectedIndex == 0) ...[
                  // Gönüllü Formu
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernInput(
                          controller: _volNameController,
                          hint: l10n.firstName,
                          icon: Icons.badge_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernInput(
                          controller: _volSurnameController,
                          hint: l10n.lastName,
                          icon: Icons.badge_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildModernInput(
                    controller: _volEmailController,
                    hint: l10n.emailAddress,
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildModernInput(
                    controller: _volPasswordController,
                    hint: l10n.passwordLabel,
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                ] else ...[
                  // STK Formu
                  _buildModernInput(
                    controller: _stkNameController,
                    hint: l10n.ngoName,
                    icon: Icons.business,
                  ),
                  const SizedBox(height: 16),
                  _buildModernInput(
                    controller: _stkEmailController,
                    hint: l10n.emailLabel,
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildModernInput(
                    controller: _stkPasswordController,
                    hint: l10n.passwordLabel,
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                ],

                const SizedBox(height: 32),

                // --- 4. KAYIT OL BUTONU ---
                BlocBuilder<SignUpCubit, SignUpState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (state is SignUpLoading)
                            ? null
                            : () => _onSignUpPressed(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kPrimaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: AppColors.kPrimaryColor.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ).copyWith(
                          elevation: WidgetStateProperty.all(8),
                          shadowColor: WidgetStateProperty.all(
                              AppColors.kPrimaryColor.withOpacity(0.4)),
                        ),
                        child: (state is SignUpLoading)
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: AppLoadingIndicator(size: 24),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.signUp,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded,
                                      size: 20),
                                ],
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // --- 5. ALT BİLGİ (Giriş Yap) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.alreadyHaveAccount,
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        l10n.loginAction,
                        style: GoogleFonts.inter(
                          color: AppColors.kSecondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          color: AppColors.kTextColor,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey.shade400,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: AppColors.kPrimaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String text,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey.shade500,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.inter(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
