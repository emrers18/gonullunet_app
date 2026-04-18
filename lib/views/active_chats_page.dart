import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/logic/active_chats_cubit/active_chats_cubit.dart';
import 'package:gonullunet_app/logic/active_chats_cubit/active_chats_state.dart';
import 'package:gonullunet_app/repo/event_chat_repository.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/views/event_chat_page.dart';
import 'package:gonullunet_app/logic/user_cubit.dart';
import 'package:gonullunet_app/logic/user_state.dart';
import 'package:gonullunet_app/models/user_model.dart' as app_user;
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
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.kBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Mesajlar',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.kTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: BlocBuilder<ActiveChatsCubit, ActiveChatsState>(
        builder: (context, state) {
          if (state is ActiveChatsLoading || state is ActiveChatsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (state is ActiveChatsError) {
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
                      state.message,
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

          if (state is ActiveChatsLoaded) {
            final activeChats = state.activeChats;

            if (activeChats.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 48,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Henüz aktif bir sohbetiniz yok',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Etkinliklere katılarak grup sohbetlerine\ndahil olabilirsiniz.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: activeChats.length,
              itemBuilder: (context, index) {
                final event = activeChats[index];
                final formatter = DateFormat('dd MMM, HH:mm', 'tr');
                final dateStr = formatter.format(event.date);

                return _ChatListCard(
                  event: event,
                  dateStr: dateStr,
                  index: index,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ChatListCard extends StatelessWidget {
  final dynamic event;
  final String dateStr;
  final int index;

  const _ChatListCard({
    required this.event,
    required this.dateStr,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final userState = context.read<UserCubit>().state;
            app_user.UserModel? currentUser;
            if (userState is UserLoaded) {
              currentUser = userState.user;
            }
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
                const SnackBar(content: Text('Kullanıcı bilgisi alınamadı.')),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                // Event Image / Icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: AppColors.primaryColor.withOpacity(0.1),
                    child: event.imageUrl.isNotEmpty
                        ? Image.network(
                            event.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.event_rounded,
                              color: AppColors.primaryColor,
                              size: 28,
                            ),
                          )
                        : const Icon(
                            Icons.event_rounded,
                            color: AppColors.primaryColor,
                            size: 28,
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                // Event Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.kTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Aç',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
