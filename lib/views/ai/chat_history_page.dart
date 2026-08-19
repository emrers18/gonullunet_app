import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
import 'package:gonullunet_app/logic/chat_cubit/chat_cubit.dart';
import 'package:gonullunet_app/logic/chat_cubit/chat_state.dart';
import 'package:gonullunet_app/models/chat_session_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/responsive.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'chat_page.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadSessions();
  }

  void _startNewChat() async {
    await context.read<ChatCubit>().startNewSession();
    if (!mounted) return;
    final state = context.read<ChatCubit>().state;
    if (state is ChatMessagesLoaded) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<ChatCubit>(),
            child: ChatPage(sessionId: state.sessionId),
          ),
        ),
      ).then((_) {
        if (mounted) {
          context.read<ChatCubit>().loadSessions();
        }
      });
    }
  }

  void _openSession(ChatSession session) {
    context.read<ChatCubit>().loadMessages(session.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ChatCubit>(),
          child: ChatPage(sessionId: session.id),
        ),
      ),
    ).then((_) {
      if (mounted) {
        context.read<ChatCubit>().loadSessions();
      }
    });
  }

  void _confirmDeleteSession(ChatSession session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.scale(context, 20))),
        title: Text(AppLocalizations.of(context).deleteChat,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Text(
          AppLocalizations.of(context).deleteChatConfirm,
          style: GoogleFonts.plusJakartaSans(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).cancel,
                style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ChatCubit>().deleteSession(session.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Responsive.scale(context, 12))),
            ),
            child: Text(AppLocalizations.of(context).delete,
                style:
                    GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // --- Gradient Hero Banner AppBar ---
          SliverAppBar(
            expandedHeight: Responsive.scale(context, 200),
            pinned: true,
            backgroundColor: AppColors.darkPrimaryColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF8C42),
                      Color(0xFF03A9F4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative background circles
                    Positioned(
                      right: Responsive.scale(context, -30),
                      top: Responsive.scale(context, -20),
                      child: Container(
                        width: Responsive.scale(context, 160),
                        height: Responsive.scale(context, 160),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      right: Responsive.scale(context, 40),
                      top: Responsive.scale(context, 50),
                      child: Container(
                        width: Responsive.scale(context, 80),
                        height: Responsive.scale(context, 80),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),
                    Positioned(
                      left: Responsive.scale(context, -20),
                      bottom: Responsive.scale(context, -10),
                      child: Container(
                        width: Responsive.scale(context, 120),
                        height: Responsive.scale(context, 120),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: Responsive.padding(context,
                          left: 20, top: 0, right: 20, bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: Responsive.padding(context, all: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(Responsive.scale(context, 14)),
                                ),
                                child: Icon(Icons.auto_awesome,
                                    color: Colors.white, size: Responsive.scale(context, 26)),
                              ),
                              SizedBox(width: Responsive.scale(context, 12)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).volunteerAi,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: Responsive.sp(context, 24),
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)
                                        .smartVolunteerAssistant,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white.withOpacity(0.75),
                                      fontSize: Responsive.sp(context, 13),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- New Chat Button ---
          SliverToBoxAdapter(
            child: Padding(
              padding: Responsive.padding(context,
                  left: 16, top: 16, right: 16, bottom: 8),
              child: _NewChatBanner(onTap: _startNewChat),
            ),
          ),

          // --- Session List Header ---
          SliverToBoxAdapter(
            child: Padding(
              padding: Responsive.padding(context,
                  left: 20, top: 8, right: 20, bottom: 8),
              child: Text(
                AppLocalizations.of(context).pastChats,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: Responsive.sp(context, 11),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // --- Session List ---
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              if (state is ChatSessionsLoading) {
                return const SliverFillRemaining(
                  child: Center(child: AppLoadingIndicator()),
                );
              }

              if (state is ChatSessionsLoaded) {
                if (state.sessions.isEmpty) {
                  return SliverFillRemaining(
                    child: _buildEmptyHistory(),
                  );
                }
                return SliverPadding(
                  padding: Responsive.padding(context,
                      left: 16, top: 0, right: 16, bottom: 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final session = state.sessions[index];
                        return _SessionCard(
                          session: session,
                          onTap: () => _openSession(session),
                          onDelete: () => _confirmDeleteSession(session),
                        );
                      },
                      childCount: state.sessions.length,
                    ),
                  ),
                );
              }

              if (state is ChatError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: Responsive.padding(context, all: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off_rounded,
                              size: Responsive.scale(context, 52), color: Colors.grey.shade300),
                          SizedBox(height: Responsive.scale(context, 16)),
                          Text(AppMessages.resolve(context, state.message),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey.shade500)),
                          SizedBox(height: Responsive.scale(context, 16)),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<ChatCubit>().loadSessions(),
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
                  ),
                );
              }

              return const SliverFillRemaining(
                child: Center(child: AppLoadingIndicator()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: Responsive.padding(context, all: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: Responsive.padding(context, all: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF004E89), Color(0xFF03A9F4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkPrimaryColor.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(Icons.auto_awesome,
                  size: Responsive.scale(context, 48), color: Colors.white),
            ),
            SizedBox(height: Responsive.scale(context, 24)),
            Text(
              AppLocalizations.of(context).aiAssistantTitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: Responsive.sp(context, 20),
                fontWeight: FontWeight.bold,
                color: AppColors.kTextColor,
              ),
            ),
            SizedBox(height: Responsive.scale(context, 10)),
            Text(
              AppLocalizations.of(context).aiHistoryIntro,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: Responsive.sp(context, 13.5),
                color: Colors.grey.shade500,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yeni sohbet başlatma banner kartı
class _NewChatBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _NewChatBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: Responsive.padding(context, all: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF5722), Color(0xFFFF8C42)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(Responsive.scale(context, 18)),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFFF5722),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: Responsive.padding(context, all: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(Responsive.scale(context, 12)),
              ),
              child: Icon(Icons.add_comment_rounded,
                  color: Colors.white, size: Responsive.scale(context, 22)),
            ),
            SizedBox(width: Responsive.scale(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).startNewChat,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.sp(context, 15),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context).askNewQuestion,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: Responsive.sp(context, 12),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white70, size: Responsive.scale(context, 16)),
          ],
        ),
      ),
    );
  }
}

/// Geçmiş sohbet kartı
class _SessionCard extends StatelessWidget {
  final ChatSession session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SessionCard({
    required this.session,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    final time = timeago.format(session.lastMessageAt.toDate(),
        locale: Localizations.localeOf(context).languageCode);

    return Padding(
      padding: Responsive.padding(context, bottom: 10),
      child: Dismissible(
        key: Key(session.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: Responsive.padding(context, right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        confirmDismiss: (_) async {
          onDelete();
          return false;
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onDelete,
            borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
            child: Container(
              padding: Responsive.padding(context, all: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: Responsive.padding(context, all: 10),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(Responsive.scale(context, 12)),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.darkPrimaryColor,
                      size: Responsive.scale(context, 20),
                    ),
                  ),
                  SizedBox(width: Responsive.scale(context, 14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: Responsive.sp(context, 14),
                            fontWeight: FontWeight.w600,
                            color: AppColors.kTextColor,
                          ),
                        ),
                        SizedBox(height: Responsive.scale(context, 3)),
                        Text(
                          time,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: Responsive.sp(context, 12),
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.grey.shade300),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
