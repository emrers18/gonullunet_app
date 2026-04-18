import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/models/event_chat_message_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import '../atoms/timestamp_text.dart';
import '../atoms/user_avatar.dart';

class MessageBubble extends StatelessWidget {
  final EventChatMessage message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 64.0 : 12.0,
        right: isMe ? 12.0 : 64.0,
        top: 4,
        bottom: 4,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            UserAvatar(avatarUrl: message.senderAvatarUrl, radius: 16),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                gradient: isMe
                    ? const LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.darkPrimaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe) ...[
                    Text(
                      message.senderName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    message.content,
                    style: GoogleFonts.plusJakartaSans(
                      color: isMe ? Colors.white : AppColors.primaryText,
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TimestampText(
                    timestamp: message.createdAt,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: isMe
                          ? Colors.white.withOpacity(0.75)
                          : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
