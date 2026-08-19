import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
import 'package:gonullunet_app/logic/chat_cubit/chat_cubit.dart';
import 'package:gonullunet_app/logic/chat_cubit/chat_state.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/responsive.dart';
import 'package:gonullunet_app/widgets/ai/chat_bubble.dart';
import 'package:gonullunet_app/widgets/ai/chat_input.dart';
import 'package:gonullunet_app/widgets/ai/typing_indicator.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';

class ChatPage extends StatefulWidget {
  final String sessionId;

  const ChatPage({super.key, required this.sessionId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadMessages(widget.sessionId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.kTextColor, size: Responsive.scale(context, 20)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: Responsive.scale(context, 34),
              height: Responsive.scale(context, 34),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF004E89), Color(0xFF03A9F4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome,
                  size: Responsive.scale(context, 18), color: Colors.white),
            ),
            SizedBox(width: Responsive.scale(context, 10)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).volunteerAi,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: Responsive.sp(context, 15),
                    fontWeight: FontWeight.bold,
                    color: AppColors.kTextColor,
                  ),
                ),
                Text(
                  AppLocalizations.of(context).smartAssistant,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: Responsive.sp(context, 11),
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
                  AppColors.darkPrimaryColor.withOpacity(0.3),
                  AppColors.primaryColor.withOpacity(0.05),
                ],
              ),
            ),
          ),
        ),
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatMessagesLoaded) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state is ChatMessagesLoaded) {
            return Column(
              children: [
                Expanded(
                  child: state.messages.isEmpty && !state.isAiTyping
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: Responsive.padding(context, vertical: 12),
                          itemCount: state.messages.length +
                              (state.isAiTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.messages.length &&
                                state.isAiTyping) {
                              return const TypingIndicator();
                            }
                            return ChatBubble(message: state.messages[index]);
                          },
                        ),
                ),
                ChatInput(
                  enabled: !state.isAiTyping,
                  onSend: (text) {
                    context.read<ChatCubit>().sendMessage(text);
                  },
                ),
              ],
            );
          }

          if (state is ChatError) {
            return Center(
              child: Padding(
                padding: Responsive.padding(context, all: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_rounded,
                        size: Responsive.scale(context, 52), color: Colors.grey.shade300),
                    SizedBox(height: Responsive.scale(context, 16)),
                    Text(
                      AppMessages.resolve(context, state.message),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey.shade500),
                    ),
                    SizedBox(height: Responsive.scale(context, 16)),
                    ElevatedButton(
                      onPressed: () => context
                          .read<ChatCubit>()
                          .loadMessages(widget.sessionId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Responsive.scale(context, 12))),
                      ),
                      child: Text('Tekrar Dene',
                          style: GoogleFonts.plusJakartaSans()),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: AppLoadingIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: Responsive.padding(context,
          left: 24, top: 32, right: 24, bottom: 24),
      child: Column(
        children: [
          // AI Avatar with gradient + glow
          Container(
            width: Responsive.scale(context, 80),
            height: Responsive.scale(context, 80),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF004E89), Color(0xFF03A9F4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkPrimaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(Icons.auto_awesome,
                size: Responsive.scale(context, 38), color: Colors.white),
          ),
          SizedBox(height: Responsive.scale(context, 20)),
          Text(
            AppLocalizations.of(context).aiGreeting,
            style: GoogleFonts.plusJakartaSans(
              fontSize: Responsive.sp(context, 22),
              fontWeight: FontWeight.bold,
              color: AppColors.kTextColor,
            ),
          ),
          SizedBox(height: Responsive.scale(context, 8)),
          Text(
            AppLocalizations.of(context).aiIntro,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: Responsive.sp(context, 14),
              color: Colors.grey.shade500,
              height: 1.6,
            ),
          ),
          SizedBox(height: Responsive.scale(context, 28)),
          // Suggestion chips
          Text(
            AppLocalizations.of(context).quickStart,
            style: GoogleFonts.plusJakartaSans(
              fontSize: Responsive.sp(context, 11),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: Responsive.scale(context, 12)),
          Wrap(
            spacing: Responsive.scale(context, 10),
            runSpacing: Responsive.scale(context, 10),
            alignment: WrapAlignment.center,
            children: [
              _SuggestionCard(
                icon: Icons.public_rounded,
                text: AppLocalizations.of(context).qErasmus,
                onTap: () => context
                    .read<ChatCubit>()
                    .sendMessage(AppLocalizations.of(context).qErasmus),
              ),
              _SuggestionCard(
                icon: Icons.volunteer_activism_rounded,
                text: AppLocalizations.of(context).qHowVolunteer,
                onTap: () => context
                    .read<ChatCubit>()
                    .sendMessage(AppLocalizations.of(context).qHowVolunteer),
              ),
              _SuggestionCard(
                icon: Icons.corporate_fare_rounded,
                text: AppLocalizations.of(context).qHowJoinNgo,
                onTap: () => context
                    .read<ChatCubit>()
                    .sendMessage(AppLocalizations.of(context).qHowJoinNgo),
              ),
              _SuggestionCard(
                icon: Icons.search_rounded,
                text: AppLocalizations.of(context).qNearbyEvents,
                onTap: () => context
                    .read<ChatCubit>()
                    .sendMessage(AppLocalizations.of(context).qNearbyEventsFull),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _SuggestionCard({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: Responsive.padding(context, horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.scale(context, 14)),
          border: Border.all(
            color: AppColors.darkPrimaryColor.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: Responsive.scale(context, 16), color: AppColors.darkPrimaryColor),
            SizedBox(width: Responsive.scale(context, 8)),
            Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w600,
                color: AppColors.darkPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
