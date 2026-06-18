import 'package:flutter/material.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';

class ChatTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;

  const ChatTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: null,
      textInputAction: TextInputAction.send,
      keyboardType: TextInputType.multiline,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText ?? AppLocalizations.of(context).messageHint,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 10.0,
        ),
      ),
    );
  }
}
