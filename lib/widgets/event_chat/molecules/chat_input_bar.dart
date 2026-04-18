import 'package:flutter/material.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import '../atoms/chat_text_field.dart';
import '../atoms/send_button.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.isLoading = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasContent = _controller.text.trim().isNotEmpty;
      if (hasContent != _hasText) {
        setState(() => _hasText = hasContent);
      }
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12.0,
        right: 12.0,
        top: 10.0,
        bottom: 10.0 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade100, width: 1.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.kBackgroundColor,
                borderRadius: BorderRadius.circular(22.0),
                border: Border.all(
                  color: _hasText
                      ? AppColors.primaryColor.withOpacity(0.4)
                      : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              child: ChatTextField(
                controller: _controller,
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          AnimatedOpacity(
            opacity: _hasText ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: SendButton(
              onPressed: _handleSend,
              isLoading: widget.isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
