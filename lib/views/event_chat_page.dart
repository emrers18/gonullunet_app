import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
import 'package:gonullunet_app/logic/event_chat_cubit/event_chat_cubit.dart';
import 'package:gonullunet_app/logic/event_chat_cubit/event_chat_state.dart';
import 'package:gonullunet_app/repo/event_chat_repository.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/event_chat/molecules/chat_input_bar.dart';
import '../widgets/event_chat/organisms/message_list_view.dart';
import '../models/user_model.dart' as app_user;

class EventChatPage extends StatelessWidget {
  final String eventId;
  final String eventTitle;
  final app_user.UserModel currentUser;

  const EventChatPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventChatCubit(
        repository: EventChatRepository(),
        eventId: eventId,
        currentUserFullName: currentUser.displayName,
        currentUserAvatarUrl: currentUser.imageUrl,
      ),
      child: _EventChatView(
        eventTitle: eventTitle,
        currentUserId: currentUser.uid,
      ),
    );
  }
}

class _EventChatView extends StatelessWidget {
  final String eventTitle;
  final String currentUserId;

  const _EventChatView({
    required this.eventTitle,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.kTextColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.kTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'Etkinlik Sohbeti',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withOpacity(0.3),
                  AppColors.primaryColor.withOpacity(0.05),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<EventChatCubit, EventChatState>(
                listener: (context, state) {
                  if (state is EventChatError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppMessages.resolve(context, state.message)),
                        backgroundColor: Colors.red.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is EventChatLoading || state is EventChatInitial) {
                    return const Center(
                      child: AppLoadingIndicator(),
                    );
                  }

                  if (state is EventChatLoaded ||
                      state is EventChatMessageSending) {
                    final messages = state is EventChatLoaded
                        ? state.messages
                        : (state as EventChatMessageSending).currentMessages;

                    return MessageListView(
                      messages: messages,
                      currentUserId:
                          FirebaseAuth.instance.currentUser?.uid ?? '',
                    );
                  }

                  if (state is EventChatError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off_rounded,
                                size: 52, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context).genericErrorMessage(
                                  AppMessages.resolve(context, state.message)),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            BlocBuilder<EventChatCubit, EventChatState>(
              builder: (context, state) {
                final isLoading = state is EventChatMessageSending;
                return ChatInputBar(
                  isLoading: isLoading,
                  onSend: (message) {
                    context.read<EventChatCubit>().sendMessage(message);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
