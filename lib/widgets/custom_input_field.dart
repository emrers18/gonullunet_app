import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CustomInputField extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const CustomInputField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText, // Şifre alanıysa metni gizle / göster
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        // Dolgu rengi
        filled: true,
        fillColor: AppColors.textColor,
        // İçerik dolgusu (padding)
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        // Suffix: göz ikonu sadece şifre alanında gösterilsin
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.accentColor,
                ),
                onPressed: _toggleObscure,
              )
            : null,
        // Normal kenarlık
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
        // Odaklanıldığında kenarlık
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide:
              const BorderSide(color: AppColors.accentColor, width: 2.0),
        ),
      ),
    );
  }
}
