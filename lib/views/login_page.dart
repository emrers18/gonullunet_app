import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
import '../services/auth.dart';
import '../services/firebase_error_translator.dart';
import '../utils/app_colors.dart';
import '../widgets/app_loading_indicator.dart';
import '../utils/validators/validators.dart';
import '../utils/responsive.dart';
import 'signUp_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Auth _auth = Auth();

  bool _isLoading = false;
  bool _isSocialLoading = false;
  bool _isObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.dmSans()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.scale(context, 10))),
      ),
    );
  }

  Future<void> _onLoginPressed() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showError(l10n.emailEmpty);
      return;
    }
    if (!AppValidators.emailReg.hasMatch(email)) {
      _showError(l10n.invalidEmailFormat);
      return;
    }
    if (password.isEmpty) {
      _showError(l10n.passwordEmpty);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.signIn(email: email, password: password);
    } catch (e) {
      if (mounted) {
        _showError(
            AppMessages.resolve(context, FirebaseErrorTranslator.translate(e)));
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _onGoogleSignInPressed() async {
    if (_isSocialLoading || _isLoading) return;

    setState(() => _isSocialLoading = true);

    try {
      final userCredential = await _auth.signInWithGoogle();
      if (userCredential == null) {
        if (mounted) setState(() => _isSocialLoading = false);
        return;
      }

      final user = userCredential.user;
      if (user != null) {
        // Kullanıcı dökümanı var mı kontrol et
        final exists = await _auth.userExists(user.uid);
        if (!exists) {
          // Yeni kullanıcı ise rol seçtir
          if (mounted) {
            await _showRoleSelectionSheet(user);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(
            AppMessages.resolve(context, FirebaseErrorTranslator.translate(e)));
      }
    }

    if (mounted) setState(() => _isSocialLoading = false);
  }

  Future<void> _showRoleSelectionSheet(User user) async {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: Responsive.padding(context, all: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Responsive.scale(context, 32)),
            topRight: Radius.circular(Responsive.scale(context, 32)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Responsive.scale(context, 40),
              height: Responsive.scale(context, 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius:
                    BorderRadius.circular(Responsive.scale(context, 2)),
              ),
            ),
            SizedBox(height: Responsive.scale(context, 24)),
            Text(
              AppLocalizations.of(context).almostReady,
              style: GoogleFonts.dmSans(
                fontSize: Responsive.sp(context, 24),
                fontWeight: FontWeight.bold,
                color: AppColors.kSecondaryColor,
              ),
            ),
            SizedBox(height: Responsive.scale(context, 8)),
            Text(
              AppLocalizations.of(context).selectUserType,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: Responsive.sp(context, 16),
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: Responsive.scale(context, 32)),
            Row(
              children: [
                Expanded(
                  child: _roleOptionCard(
                    title: AppLocalizations.of(context).roleVolunteer,
                    subtitle: AppLocalizations.of(context).roleVolunteerDesc,
                    icon: Icons.person_outline,
                    color: AppColors.kPrimaryColor,
                    onTap: () async {
                      await _auth.createProfile(
                        user: user,
                        userType: 'volunteer',
                        displayName: user.displayName,
                        photoUrl: user.photoURL,
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(width: Responsive.scale(context, 16)),
                Expanded(
                  child: _roleOptionCard(
                    title: AppLocalizations.of(context).roleNgo,
                    subtitle: AppLocalizations.of(context).roleNgoDesc,
                    icon: Icons.business_outlined,
                    color: AppColors.kSecondaryColor,
                    onTap: () async {
                      await _auth.createProfile(
                        user: user,
                        userType: 'ngo',
                        displayName: user.displayName,
                        photoUrl: user.photoURL,
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.scale(context, 24)),
          ],
        ),
      ),
    );
  }

  Widget _roleOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Responsive.scale(context, 20)),
      child: Container(
        padding: Responsive.padding(context, all: 20),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.2), width: 2),
          borderRadius: BorderRadius.circular(Responsive.scale(context, 20)),
          color: color.withOpacity(0.05),
        ),
        child: Column(
          children: [
            Icon(icon, size: Responsive.scale(context, 40), color: color),
            SizedBox(height: Responsive.scale(context, 12)),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: Responsive.scale(context, 4)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: Responsive.sp(context, 12),
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: Responsive.padding(context,
                      horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top + 20),
                      Container(
                        width: Responsive.scale(context, 175),
                        height: Responsive.scale(context, 175),
                        padding: Responsive.padding(context, all: 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.kPrimaryColor.withOpacity(0.1),
                        ),
                        child: Image.asset(
                          'lib/assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (c, o, s) => Icon(
                              Icons.volunteer_activism,
                              color: AppColors.kPrimaryColor,
                              size: Responsive.scale(context, 40)),
                        ),
                      ),
                      SizedBox(height: Responsive.scale(context, 24)),
                      Text(
                        l10n.welcomeBack,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: Responsive.sp(context, 28),
                          fontWeight: FontWeight.w800,
                          color: AppColors.kPrimaryColor,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: Responsive.scale(context, 8)),
                      Text(
                        l10n.loginSubtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: Responsive.sp(context, 16),
                          fontWeight: FontWeight.w500,
                          color: AppColors.kTextMain.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: Responsive.scale(context, 40)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                Responsive.padding(context, left: 4, bottom: 8),
                            child: Text(
                              l10n.emailLabel,
                              style: GoogleFonts.dmSans(
                                fontSize: Responsive.sp(context, 14),
                                fontWeight: FontWeight.bold,
                                color: AppColors.kTextMain,
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.dmSans(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _inputDecoration(
                              hint: l10n.emailHint,
                              suffixIcon: const Icon(Icons.mail_outline,
                                  color: Colors.grey),
                            ),
                          ),
                          SizedBox(height: Responsive.scale(context, 20)),
                          Padding(
                            padding:
                                Responsive.padding(context, left: 4, bottom: 8),
                            child: Text(
                              l10n.passwordLabel,
                              style: GoogleFonts.dmSans(
                                fontSize: Responsive.sp(context, 14),
                                fontWeight: FontWeight.bold,
                                color: AppColors.kTextMain,
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _isObscure,
                            style: GoogleFonts.dmSans(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _inputDecoration(
                              hint: "••••••••",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            l10n.forgotPassword,
                            style: GoogleFonts.dmSans(
                              color: AppColors.kTextMain.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                              fontSize: Responsive.sp(context, 14),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.scale(context, 8)),
                      SizedBox(
                        width: double.infinity,
                        height: Responsive.scale(context, 56),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onLoginPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kPrimaryColor,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor:
                                AppColors.kPrimaryColor.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  Responsive.scale(context, 12)),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: Responsive.scale(context, 24),
                                  height: Responsive.scale(context, 24),
                                  child: AppLoadingIndicator(
                                      size: Responsive.scale(context, 24)),
                                )
                              : Text(
                                  l10n.login,
                                  style: GoogleFonts.dmSans(
                                    fontSize: Responsive.sp(context, 18),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: Responsive.scale(context, 32)),
                      // Row(
                      //   children: [
                      //     const Expanded(child: Divider()),
                      //     Padding(
                      //       padding: const EdgeInsets.symmetric(horizontal: 16),
                      //       child: Text(
                      //         "veya şununla devam et",
                      //         style: GoogleFonts.dmSans(
                      //           color: Colors.grey.shade500,
                      //           fontSize: 14,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     ),
                      //     const Expanded(child: Divider()),
                      //   ],
                      // ),
                      // const SizedBox(height: 24),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: _socialButton(
                      //         label: "Google",
                      //         icon: Icons.g_mobiledata,
                      //         color: const Color(0xFFEA4335),
                      //         isLoading: _isSocialLoading,
                      //         onTap: _onGoogleSignInPressed,
                      //       ),
                      //     ),
                      //     const SizedBox(width: 16),
                      //     Expanded(
                      //       child: _socialButton(
                      //         label: "Apple",
                      //         icon: Icons.apple,
                      //         color: Colors.black,
                      //         isLoading: false,
                      //         onTap: () {
                      //           _showError(
                      //               "Apple ile giriş şu an aktif değil.");
                      //         },
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const Spacer(),
                      Padding(
                        padding:
                            Responsive.padding(context, top: 24, bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.noAccount,
                              style: GoogleFonts.dmSans(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SignUpPage()),
                                );
                              },
                              child: Text(
                                l10n.signUp,
                                style: const TextStyle(
                                  color: AppColors.kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: Responsive.padding(context, horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.scale(context, 12)),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.scale(context, 12)),
        borderSide: const BorderSide(color: AppColors.kPrimaryColor, width: 2),
      ),
    );
  }

  Widget _socialButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    final isDisabled = _isLoading || _isSocialLoading;

    return Container(
      height: Responsive.scale(context, 56),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (isDisabled || isLoading) ? null : onTap,
          borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: Responsive.scale(context, 20),
                    height: Responsive.scale(context, 20),
                    child: AppLoadingIndicator(
                        size: Responsive.scale(context, 20)),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon,
                          color: color, size: Responsive.scale(context, 28)),
                      SizedBox(width: Responsive.scale(context, 10)),
                      Text(
                        label,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: Responsive.sp(context, 16),
                          color: AppColors.kSecondaryColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
