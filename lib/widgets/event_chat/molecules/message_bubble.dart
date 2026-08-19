import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/models/event_chat_message_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/responsive.dart';
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
      padding: Responsive.padding(
        context,
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
            UserAvatar(
                avatarUrl: message.senderAvatarUrl,
                radius: Responsive.scale(context, 16)),
            SizedBox(width: Responsive.scale(context, 8)),
          ],
          Flexible(
            child: Container(
              padding: Responsive.padding(
                context,
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
                  topLeft: Radius.circular(Responsive.scale(context, 18)),
                  topRight: Radius.circular(Responsive.scale(context, 18)),
                  bottomLeft: Radius.circular(Responsive.scale(context, isMe ? 18 : 4)),
                  bottomRight: Radius.circular(Responsive.scale(context, isMe ? 4 : 18)),
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
                        fontSize: Responsive.sp(context, 12),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: Responsive.scale(context, 3)),
                  ],
                  Text(
                    message.content,
                    style: GoogleFonts.plusJakartaSans(
                      color: isMe ? Colors.white : AppColors.primaryText,
                      fontSize: Responsive.sp(context, 14.5),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: Responsive.scale(context, 4)),
                  TimestampText(
                    timestamp: message.createdAt,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: Responsive.sp(context, 10),
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
