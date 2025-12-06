// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:gonullunet_app/widgets/custom_input_field.dart';
import 'package:gonullunet_app/services/auth.dart'; // Auth servisi
import 'package:firebase_auth/firebase_auth.dart'; // Hata yakalamak için
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore için
import 'package:gonullunet_app/utils/validators/validators.dart';

import '../utils/app_colors.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Toggle button'ların durumunu tutmak için 0: Gönüllü, 1: STK
  final List<bool> _isSelected = [true, false];

  final TextEditingController _volNameController = TextEditingController();
  final TextEditingController _volSurnameController = TextEditingController();
  final TextEditingController _volEmailController = TextEditingController();
  final TextEditingController _volPasswordController = TextEditingController();

  final TextEditingController _stkNameController = TextEditingController();
  final TextEditingController _stkEmailController = TextEditingController();
  final TextEditingController _stkPasswordController = TextEditingController();

  final Auth _auth = Auth();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

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
        content: Text(message),
        backgroundColor: AppColors.accentColor,
      ),
    );
  }

  // Kayıt ola basılınca => Firebase ile kayıt
  void _onSignUpPressed() async {
    String name, surname, email, password, userType;

    if (_isSelected[1]) {
      name = _stkNameController.text.trim();
      email = _stkEmailController.text.trim();
      password = _stkPasswordController.text;
      surname = '';
      userType = 'ngo';

      if (name.isEmpty) return _showError('STK adı boş bırakılamaz.');
    } else {
      name = _volNameController.text.trim();
      surname = _volSurnameController.text.trim();
      email = _volEmailController.text.trim();
      password = _volPasswordController.text;
      userType = 'volunteer';

      if (name.isEmpty) return _showError('Ad boş bırakılamaz.');
      if (surname.isEmpty) return _showError('Soyad boş bırakılamaz.');
    }

    if (email.isEmpty) return _showError('E-posta boş bırakılamaz.');
    if (!AppValidators.emailReg.hasMatch(email)) {
      return _showError('Geçersiz e-posta adresi.');
    }
    if (password.isEmpty) return _showError('Şifre boş bırakılamaz.');
    if (!AppValidators.passwordReg.hasMatch(password)) {
      return _showError(
          'Şifre zayıf. En az 8 karakter, büyük/küçük harf, rakam ve özel karakter içermelidir.');
    }

    setState(() {
      _isLoading = true;
    });

    //firebase auth ile kayıt işlemi
    try {
      //kullanıcı oluşturma
      UserCredential userCredential =
          await _auth.createUser(email: email, password: password);

      //kullanıcı uid'sini alma
      String uid = userCredential.user!.uid;

      //firestorea kaydetme
      Map<String, dynamic> userData = {
        'uid': uid,
        'email': email,
        'userType': userType,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (userType == 'ngo') {
        userData['stkName'] = name;
      } else {
        userData['name'] = name;
        userData['surname'] = surname;
      }

      await _firestore.collection('users').doc(uid).set(userData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Kayıt başarılı! Giriş sayfasına yönlendiriliyorsunuz.'),
            backgroundColor: AppColors.primaryColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showError('Bu e-posta adresi zaten kullanılıyor.');
      } else {
        _showError('Kayıt hatası: ${e.message}');
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
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.kBackgroundColor,
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
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Genişlik boyunca gerilme
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
              if (_isSelected[1]) ...[
                CustomInputField(
                  key: const ValueKey('stk_name'),
                  hintText: 'STK Adı',
                  controller: _stkNameController,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  key: const ValueKey('stk_email'),
                  hintText: 'E-posta',
                  controller: _stkEmailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  key: const ValueKey('stk_password'),
                  hintText: 'Şifre',
                  isPassword: true,
                  controller: _stkPasswordController,
                ),
              ] else ...[
                CustomInputField(
                  key: const ValueKey('vol_name'),
                  hintText: 'Ad',
                  controller: _volNameController,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  key: const ValueKey('vol_surname'),
                  hintText: 'Soyad',
                  controller: _volSurnameController,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  key: const ValueKey('vol_email'),
                  hintText: 'E-posta',
                  controller: _volEmailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  key: const ValueKey('vol_password'),
                  hintText: 'Şifre',
                  isPassword: true,
                  controller: _volPasswordController,
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _onSignUpPressed,
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
                        'Kayıt Ol',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
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

//toggle değişince diğer kullanıcı tipinin controllerları temizlenir
  void _onToggleChanged(int index) {
    setState(() {
      for (int i = 0; i < _isSelected.length; i++) {
        _isSelected[i] = i == index;
      }
      if (index == 0) {
        _stkNameController.clear();
        _stkEmailController.clear();
        _stkPasswordController.clear();
      } else {
        _volNameController.clear();
        _volSurnameController.clear();
        _volEmailController.clear();
        _volPasswordController.clear();
      }
    });
  }

  Widget _buildToggleChild(String text, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => _onToggleChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
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
