import 'package:flutter/material.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/responsive.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool enabled;

  const ChatInput({
    super.key,
    required this.onSend,
    this.enabled = true,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: Responsive.scale(context, 12),
        right: Responsive.scale(context, 8),
        top: Responsive.scale(context, 8),
        bottom: MediaQuery.of(context).padding.bottom + Responsive.scale(context, 8),
      ),
      decoration: BoxDecoration(
        color: AppColors.kSurfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              minLines: 1,
              style: TextStyle(
                fontSize: Responsive.sp(context, 15),
                color: AppColors.primaryText,
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).messageHint,
                hintStyle: TextStyle(
                  color: AppColors.secondaryText.withOpacity(0.6),
                  fontSize: Responsive.sp(context, 15),
                ),
                filled: true,
                fillColor: AppColors.kBackgroundColor,
                contentPadding: Responsive.padding(
                  context,
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Responsive.scale(context, 24)),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          SizedBox(width: Responsive.scale(context, 6)),
          Material(
            color: _hasText && widget.enabled
                ? AppColors.accentColor
                : AppColors.dividerColor,
            borderRadius: BorderRadius.circular(Responsive.scale(context, 24)),
            child: InkWell(
              borderRadius: BorderRadius.circular(Responsive.scale(context, 24)),
              onTap: _hasText && widget.enabled ? _handleSend : null,
              child: Container(
                padding: Responsive.padding(context, all: 10),
                child: Icon(
                  Icons.send_rounded,
                  color: _hasText && widget.enabled
                      ? Colors.white
                      : AppColors.secondaryText,
                  size: Responsive.scale(context, 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
