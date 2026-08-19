import 'package:flutter/material.dart';
import 'package:gonullunet_app/models/chat_message_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/responsive.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: Responsive.padding(
          context,
          top: 4,
          bottom: 4,
          left: isUser ? 48 : 8,
          right: isUser ? 8 : 48,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              CircleAvatar(
                radius: Responsive.scale(context, 16),
                backgroundColor: AppColors.darkPrimaryColor,
                child: Icon(
                  Icons.auto_awesome,
                  size: Responsive.scale(context, 18),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: Responsive.scale(context, 8)),
            ],
            Flexible(
              child: Container(
                padding: Responsive.padding(
                  context,
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppColors.darkPrimaryColor
                      : AppColors.kCardBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Responsive.scale(context, 16)),
                    topRight: Radius.circular(Responsive.scale(context, 16)),
                    bottomLeft: Radius.circular(
                        Responsive.scale(context, isUser ? 16 : 4)),
                    bottomRight: Radius.circular(
                        Responsive.scale(context, isUser ? 4 : 16)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isUser ? Colors.white : AppColors.primaryText,
                    fontSize: Responsive.sp(context, 14.5),
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
