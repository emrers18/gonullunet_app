import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/validators/validators.dart';
import 'package:gonullunet_app/widgets/custom_input_field.dart';

import '../logic/signup_cubit.dart';
import '../logic/signup_state.dart';

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
  final List<bool> _isSelected = [true, false];

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
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onSignUpPressed(BuildContext context) {
    String name = '', surname = '', email = '', password = '', userType = '';
    String? stkName;

    if (_isSelected[1]) {
      // STK
      stkName = _stkNameController.text.trim();
      email = _stkEmailController.text.trim();
      password = _stkPasswordController.text;
      userType = 'ngo';

      if (stkName.isEmpty) return _showError('STK adı boş bırakılamaz.');
    } else {
      // Gönüllü
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
      body: BlocListener<SignUpCubit, SignUpState>(
        listener: (context, state) {
          if (state is SignUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Kayıt başarılı! Giriş sayfasına yönlendiriliyorsunuz.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is SignUpError) {
            _showError(state.message);
          }
        },
        child: SingleChildScrollView(
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
                BlocBuilder<SignUpCubit, SignUpState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: (state is SignUpLoading)
                          ? null
                          : () => _onSignUpPressed(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentColor,
                        foregroundColor: AppColors.textColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: (state is SignUpLoading)
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3),
                            )
                          : const Text(
                              'Kayıt Ol',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
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
      ),
    );
  }

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
                  const BoxShadow(
                    color: Colors.black,
                    blurRadius: 4,
                    offset: Offset(0, 2),
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
