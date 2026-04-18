import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/logic/chat_cubit/chat_cubit.dart';
import 'package:gonullunet_app/logic/chat_cubit/chat_state.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/widgets/ai/chat_bubble.dart';
import 'package:gonullunet_app/widgets/ai/chat_input.dart';
import 'package:gonullunet_app/widgets/ai/typing_indicator.dart';

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.kTextColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF004E89), Color(0xFF03A9F4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome,
                  size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gönüllü AI',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kTextColor,
                  ),
                ),
                Text(
                  'Akıllı Asistan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_rounded,
                        size: 52, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<ChatCubit>()
                          .loadMessages(widget.sessionId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
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
            child: CircularProgressIndicator(
              color: AppColors.darkPrimaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          // AI Avatar with gradient + glow
          Container(
            width: 80,
            height: 80,
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
            child: const Icon(Icons.auto_awesome,
                size: 38, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            'Merhaba! 👋',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.kTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ben GönüllüNet AI Asistanı.\nErasmus+, gönüllülük projeleri ve STK\'lar\nhakkında sorularınızı yanıtlayabilirim.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          // Suggestion chips
          Text(
            'HIZLI BAŞLANGIÇ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _SuggestionCard(
                icon: Icons.public_rounded,
                text: 'Erasmus+ nedir?',
                onTap: () => context.read<ChatCubit>().sendMessage('Erasmus+ nedir?'),
              ),
              _SuggestionCard(
                icon: Icons.volunteer_activism_rounded,
                text: 'Nasıl gönüllü olabilirim?',
                onTap: () => context.read<ChatCubit>().sendMessage('Nasıl gönüllü olabilirim?'),
              ),
              _SuggestionCard(
                icon: Icons.corporate_fare_rounded,
                text: 'STK\'lara nasıl katılırım?',
                onTap: () => context.read<ChatCubit>().sendMessage('STK\'lara nasıl katılırım?'),
              ),
              _SuggestionCard(
                icon: Icons.search_rounded,
                text: 'Bana yakın etkinlikler',
                onTap: () => context.read<ChatCubit>().sendMessage('Bana yakın gönüllülük etkinlikleri nelerdir?'),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
            Icon(icon, size: 16, color: AppColors.darkPrimaryColor),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
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
