import 'package:flutter/material.dart';
import 'package:gonullunet_app/widgets/custom_input_field.dart';

import '../utils/app_colors.dart';

const Color kPrimaryColor = Color(0xFFFF5722);
const Color kBackgroundColor = Color(0xFFF5F5F5);

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Toggle button'ların durumunu tutmak için  0: Gönüllü, 1: STK
  final List<bool> _isSelected = [true, false];

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final RegExp _emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp _passwordReg =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentColor,
      ),
    );
  }

  void _onSignUpPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showError('E-posta boş bırakılamaz.');
      return;
    }
    if (!_emailReg.hasMatch(email)) {
      _showError('Geçersiz e-posta adresi.');
      return;
    }

    if (password.isEmpty) {
      _showError('Şifre boş bırakılamaz.');
      return;
    }
    if (!_passwordReg.hasMatch(password)) {
      _showError(
          'Şifre zayıf. En az 8 karakter, büyük/küçük harf, rakam ve özel karakter içermelidir.');
      return;
    }

    // Geçerliyse kayıt mantığı buraya eklenecek
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kayıt bilgileri geçerli. Devam ediliyor...'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        // Geri butonu
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('GönüllüNet'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildToggleChild('Gönüllü', _isSelected[0], 0),
                    ),
                    Expanded(
                      child: _buildToggleChild('STK', _isSelected[1], 1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Eğer STK seçili ise sadece STK ADI, E-posta ve Şifre göster
              if (_isSelected[1]) ...[
                // benzersiz Key'ler ekledim
                const CustomInputField(
                    key: ValueKey('stk_name'), hintText: 'STK Adı'),
                const SizedBox(height: 16),
                CustomInputField(
                  key: const ValueKey('stk_email'),
                  hintText: 'E-posta',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  key: const ValueKey('stk_password'),
                  hintText: 'Şifre',
                  isPassword: true,
                  controller: _passwordController,
                ),
              ] else ...[
                // Gönüllü seçili ise farklı Key'lerle alanlar
                const CustomInputField(
                    key: ValueKey('vol_name'), hintText: 'Ad'),
                const SizedBox(height: 16),
                const CustomInputField(
                    key: ValueKey('vol_surname'), hintText: 'Soyad'),
                const SizedBox(height: 16),
                CustomInputField(
                  key: const ValueKey('vol_email'),
                  hintText: 'E-posta',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  key: const ValueKey('vol_password'),
                  hintText: 'Şifre',
                  isPassword: true,
                  controller: _passwordController,
                ),
              ],

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _onSignUpPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  foregroundColor: AppColors.textColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Kayıt Ol',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Zaten bir hesabın var mı? Giriş yap
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    // Giriş yap sayfasına geri dön
                    Navigator.of(context).pop();
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                      children: const [
                        TextSpan(text: 'Zaten bir hesabın var mı? '),
                        TextSpan(
                          text: 'Giriş yap',
                          style: TextStyle(
                            color: AppColors.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  // ToggleButonlar için özel child widget
  Widget _buildToggleChild(String text, bool isSelected, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          for (int i = 0; i < _isSelected.length; i++) {
            _isSelected[i] = i == index;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.transparent, // Seçili ise beyaz
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.accentColor : Colors.grey[700],
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
