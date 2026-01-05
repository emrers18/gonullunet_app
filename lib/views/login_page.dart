import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth.dart';
import '../utils/app_colors.dart';
import '../utils/validators/validators.dart';
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
  bool _isObscure = true; // Şifre görünürlüğü için

  static const Color kPrimaryColor = Color(0xFFFF6B35);
  static const Color kSecondaryColor = Color(0xFF004E89);
  static const Color kBackgroundColor = Color(0xFFF7F9FC);
  static const Color kInputFillColor = Colors.white;
  static const Color kBorderColor = Color(0xFFE5E7EB);

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _onLoginPressed() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validasyonlar
    if (email.isEmpty) {
      _showError('E-posta boş bırakılamaz.');
      return;
    }
    if (!AppValidators.emailReg.hasMatch(email)) {
      _showError('Geçersiz e-posta formatı.');
      return;
    }
    if (password.isEmpty) {
      _showError('Şifre boş bırakılamaz.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.signIn(email: email, password: password);
      // Başarılı giriş sonrası yönlendirme main.dart'taki AuthGate ile otomatik olacak
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showError('Kullanıcı bulunamadı.');
      } else if (e.code == 'wrong-password') {
        _showError('Hatalı şifre.');
      } else if (e.code == 'invalid-credential') {
        _showError('Geçersiz bilgiler.');
      } else {
        _showError('Giriş hatası: ${e.message}');
      }
    } catch (e) {
      _showError('Bir hata oluştu: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top + 20),

                      Container(
                        width: 175,
                        height: 175,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kPrimaryColor.withOpacity(0.1),
                        ),
                        child: Image.asset(
                          'lib/assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (c, o, s) => const Icon(
                              Icons.volunteer_activism,
                              color: kPrimaryColor,
                              size: 40),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Tekrar Hoş Geldin!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.kPrimaryColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "İyilik yolculuğuna kaldığın yerden devam et.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1F2937).withOpacity(0.7),
                        ),
                      ),

                      const SizedBox(height: 40),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              "E-posta",
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
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
                              hint: "merhaba@ornek.com",
                              suffixIcon: const Icon(Icons.mail_outline,
                                  color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              "Şifre",
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
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
                          onPressed: () {
                            // Şifre sıfırlama işlemi
                          },
                          child: Text(
                            "Şifremi Unuttum?",
                            style: GoogleFonts.dmSans(
                              color: const Color(0xFF1F2937).withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // --- 3. GİRİŞ BUTONU ---
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onLoginPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: kPrimaryColor.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  "Giriş Yap",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // --- 4. DIVIDER ---
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: Color(0xFFE5E7EB))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "veya şununla devam et",
                              style: GoogleFonts.dmSans(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(
                              child: Divider(color: Color(0xFFE5E7EB))),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // --- 5. SOSYAL BUTONLAR ---
                      Row(
                        children: [
                          Expanded(
                              child: _socialButton(
                                  label: "Google",
                                  icon: Icons.g_mobiledata,
                                  color: Colors.red)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _socialButton(
                                  label: "Apple",
                                  icon: Icons.apple,
                                  color: Colors.black)),
                        ],
                      ),
                      const Spacer(),

                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Hesabın yok mu?",
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
                                "Kayıt Ol",
                                style: GoogleFonts.dmSans(
                                  color: kPrimaryColor,
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
      hintStyle: GoogleFonts.dmSans(color: Colors.grey.shade400),
      filled: true,
      fillColor: kInputFillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: kPrimaryColor, width: 2), // Focus ring
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  Widget _socialButton(
      {required String label, required IconData icon, required Color color}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: kBorderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                color: kSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
