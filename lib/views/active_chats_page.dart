import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/logic/active_chats_cubit/active_chats_cubit.dart';
import 'package:gonullunet_app/logic/active_chats_cubit/active_chats_state.dart';
import 'package:gonullunet_app/repo/event_chat_repository.dart';
import 'package:gonullunet_app/views/event_chat_page.dart';
import 'package:gonullunet_app/logic/user_cubit.dart';
import 'package:gonullunet_app/logic/user_state.dart';
import 'package:gonullunet_app/models/user_model.dart' as app_user;
import 'package:gonullunet_app/utils/responsive.dart';
import 'package:intl/intl.dart';

class ActiveChatsPage extends StatelessWidget {
  const ActiveChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActiveChatsCubit(repository: EventChatRepository()),
      child: const _ActiveChatsView(),
    );
  }
}

class _ActiveChatsView extends StatelessWidget {
  const _ActiveChatsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Column(
        children: [
          // ── Mavi Gradient Header ──
          _buildHeader(context),

          // ── İçerik ──
          Expanded(
            child: BlocBuilder<ActiveChatsCubit, ActiveChatsState>(
              builder: (context, state) {
                if (state is ActiveChatsLoading ||
                    state is ActiveChatsInitial) {
                  return _buildShimmer(context);
                }

                if (state is ActiveChatsError) {
                  return _buildError(
                      AppMessages.resolve(context, state.message), context);
                }

                if (state is ActiveChatsLoaded) {
                  final chats = state.activeChats;
                  if (chats.isEmpty) return _buildEmpty(context);

                  return RefreshIndicator(
                    color: const Color(0xFF1565C0),
                    onRefresh: () async {
                      context.read<ActiveChatsCubit>().reload();
                    },
                    child: ListView.builder(
                      padding: Responsive.padding(context,
                          left: 16, top: 16, right: 16, bottom: 24),
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final event = chats[index];
                        return _ChatCard(event: event, index: index);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Responsive.scale(context, 28)),
          bottomRight: Radius.circular(Responsive.scale(context, 28)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: Responsive.padding(context,
              left: 20, top: 16, right: 20, bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).navMessages,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: Responsive.sp(context, 28),
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    width: Responsive.scale(context, 40),
                    height: Responsive.scale(context, 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_chat_read_rounded,
                      color: Colors.white,
                      size: Responsive.scale(context, 20),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.scale(context, 6)),
              Text(
                AppLocalizations.of(context).groupChatsSubtitle,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: Responsive.sp(context, 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return ListView.builder(
      padding: Responsive.padding(context,
          left: 16, top: 16, right: 16, bottom: 24),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: Responsive.padding(context, bottom: 12),
          child: Container(
            height: Responsive.scale(context, 88),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.scale(context, 18)),
            ),
            child: Row(
              children: [
                SizedBox(width: Responsive.scale(context, 14)),
                Container(
                  width: Responsive.scale(context, 56),
                  height: Responsive.scale(context, 56),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(Responsive.scale(context, 14)),
                  ),
                ),
                SizedBox(width: Responsive.scale(context, 14)),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: Responsive.scale(context, 14),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(Responsive.scale(context, 8)),
                          )),
                      SizedBox(height: Responsive.scale(context, 8)),
                      Container(
                          height: Responsive.scale(context, 11),
                          width: Responsive.scale(context, 120),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(Responsive.scale(context, 8)),
                          )),
                    ],
                  ),
                ),
                SizedBox(width: Responsive.scale(context, 14)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(String message, BuildContext context) {
    return Center(
      child: Padding(
        padding: Responsive.padding(context, all: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: Responsive.padding(context, all: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_off_rounded,
                  size: Responsive.scale(context, 44), color: Colors.red.shade300),
            ),
            SizedBox(height: Responsive.scale(context, 20)),
            Text(
              AppLocalizations.of(context).connectionError,
              style: GoogleFonts.plusJakartaSans(
                fontSize: Responsive.sp(context, 17),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            SizedBox(height: Responsive.scale(context, 8)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey.shade500,
                fontSize: Responsive.sp(context, 13),
                height: 1.5,
              ),
            ),
            SizedBox(height: Responsive.scale(context, 24)),
            ElevatedButton.icon(
              onPressed: () => context.read<ActiveChatsCubit>().reload(),
              icon: Icon(Icons.refresh_rounded, size: Responsive.scale(context, 18)),
              label: Text(AppLocalizations.of(context).retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: Responsive.padding(context, horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.scale(context, 14))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: Responsive.padding(context, all: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: Responsive.scale(context, 100),
              height: Responsive.scale(context, 100),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.forum_rounded,
                size: Responsive.scale(context, 44),
                color: Colors.white,
              ),
            ),
            SizedBox(height: Responsive.scale(context, 28)),
            Text(
              AppLocalizations.of(context).noActiveChats,
              style: GoogleFonts.plusJakartaSans(
                fontSize: Responsive.sp(context, 19),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            SizedBox(height: Responsive.scale(context, 10)),
            Text(
              AppLocalizations.of(context).joinEventsForChats,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: Responsive.sp(context, 14),
                color: Colors.grey.shade500,
                height: 1.6,
              ),
            ),
            SizedBox(height: Responsive.scale(context, 32)),
            ElevatedButton.icon(
              onPressed: () => Navigator.maybePop(context),
              icon: Icon(Icons.explore_rounded, size: Responsive.scale(context, 18)),
              label: Text(AppLocalizations.of(context).discoverEvents),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: Responsive.padding(context, horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.scale(context, 16))),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chat Kartı ──

class _ChatCard extends StatelessWidget {
  final dynamic event;
  final int index;

  const _ChatCard({required this.event, required this.index});

  void _openChat(BuildContext context) {
    final userState = context.read<UserCubit>().state;
    app_user.UserModel? currentUser;
    if (userState is UserLoaded) currentUser = userState.user;

    if (currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventChatPage(
            eventId: event.id,
            eventTitle: event.title,
            currentUser: currentUser!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).userInfoUnavailable)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM', 'tr');
    final dateStr = formatter.format(event.date);
    final isProject = event.type == 'Proje';

    return Padding(
      padding: Responsive.padding(context, bottom: 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Responsive.scale(context, 18)),
        child: InkWell(
          onTap: () => _openChat(context),
          borderRadius: BorderRadius.circular(Responsive.scale(context, 18)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.scale(context, 18)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Sol renk şeridi
                Container(
                  width: Responsive.scale(context, 4),
                  height: Responsive.scale(context, 80),
                  decoration: BoxDecoration(
                    color: isProject
                        ? AppColors.kPrimaryColor
                        : const Color(0xFF1565C0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Responsive.scale(context, 18)),
                      bottomLeft: Radius.circular(Responsive.scale(context, 18)),
                    ),
                  ),
                ),

                SizedBox(width: Responsive.scale(context, 14)),

                // Etkinlik resmi / ikon
                ClipRRect(
                  borderRadius: BorderRadius.circular(Responsive.scale(context, 14)),
                  child: Container(
                    width: Responsive.scale(context, 56),
                    height: Responsive.scale(context, 56),
                    color: isProject
                        ? AppColors.kPrimaryColor
                        : const Color(0xFF1565C0).withOpacity(0.08),
                    child: event.imageUrl != null && event.imageUrl.isNotEmpty
                        ? Image.network(
                            event.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              isProject
                                  ? Icons.work_rounded
                                  : Icons.event_rounded,
                              color: isProject
                                  ? AppColors.kPrimaryColor
                                  : const Color(0xFF1565C0),
                              size: Responsive.scale(context, 26),
                            ),
                          )
                        : Icon(
                            isProject
                                ? Icons.work_rounded
                                : Icons.event_rounded,
                            color: isProject
                                ? AppColors.kPrimaryColor
                                : const Color(0xFF1565C0),
                            size: Responsive.scale(context, 26),
                          ),
                  ),
                ),

                SizedBox(width: Responsive.scale(context, 14)),

                // Bilgi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: Responsive.sp(context, 14),
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                          if (isProject)
                            Container(
                              margin: Responsive.padding(context, left: 6),
                              padding: Responsive.padding(context,
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(Responsive.scale(context, 8)),
                              ),
                              child: Text(
                                'Proje',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: Responsive.sp(context, 10),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.kPrimaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: Responsive.scale(context, 5)),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: Responsive.scale(context, 11), color: Colors.grey.shade400),
                          SizedBox(width: Responsive.scale(context, 4)),
                          Text(
                            dateStr,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: Responsive.sp(context, 12),
                              color: Colors.grey.shade500,
                            ),
                          ),
                          SizedBox(width: Responsive.scale(context, 10)),
                          Icon(Icons.location_on_outlined,
                              size: Responsive.scale(context, 11), color: Colors.grey.shade400),
                          SizedBox(width: Responsive.scale(context, 3)),
                          Expanded(
                            child: Text(
                              event.location ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: Responsive.sp(context, 12),
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: Responsive.scale(context, 12)),

                // Ok ikonu
                Container(
                  width: Responsive.scale(context, 34),
                  height: Responsive.scale(context, 34),
                  decoration: BoxDecoration(
                    color: isProject
                        ? AppColors.accentColor.withOpacity(0.1)
                        : const Color(0xFF1565C0).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: Responsive.scale(context, 20),
                    color: isProject
                        ? AppColors.kPrimaryColor
                        : const Color(0xFF1565C0),
                  ),
                ),

                SizedBox(width: Responsive.scale(context, 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
