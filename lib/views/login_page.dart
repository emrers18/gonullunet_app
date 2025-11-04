import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../widgets/custom_input_field.dart';
import '../utils/app_colors.dart';
import 'signUp_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final RegExp _emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  final Auth _auth = Auth();
  bool _isLoading = false;

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
        content: Text(message),
        backgroundColor: AppColors.accentColor,
      ),
    );
  }

  Future<void> _onLoginPressed() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showError('E-posta boş bırakılamaz.');
      return;
    }

    if (!_emailReg.hasMatch(email)) {
      _showError(
          'Geçersiz e-posta adresi. Lütfen doğru formatta girin (ör: ornek@domain.com).');
      return;
    }
    if (password.isEmpty) {
      _showError('Şifre boş bırakılamaz.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showError('Bu e-posta ile kayıtlı bir kullanıcı bulunamadı.');
      } else if (e.code == 'wrong-password') {
        _showError('Yanlış şifre girdiniz.');
      } else if (e.code == 'invalid-credential') {
        _showError('Geçersiz kullanıcı bilgileri.');
      } else {
        _showError('Giriş yapılamadı: ${e.message}');
      }
    } catch (e) {
      _showError('Bilinmeyen bir hata oluştu: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GönüllüNet'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // tam geniş buton
            children: [
              const SizedBox(height: 40),
              CustomInputField(
                hintText: 'E-posta',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                hintText: 'Şifre',
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _onLoginPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  foregroundColor: AppColors.textColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Giriş Yap',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ));
                  },
                  child: const Text(
                    'Hesabın yoksa kayıt ol!',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
