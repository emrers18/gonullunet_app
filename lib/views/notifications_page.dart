import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
import 'package:gonullunet_app/utils/app_colors.dart';

import '../logic/notidication_state.dart';
import '../logic/notifications_cubit.dart';
import '../repo/notification_repository.dart';
import '../widgets/app_loading_indicator.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          NotificationCubit(NotificationRepository())..loadNotifications(),
      child: const NotificationsView(),
    );
  }
}

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).notifications,
          style: const TextStyle(
              color: AppColors.kTextColor,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.kBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded &&
                  state.notifications.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined,
                      color: Colors.redAccent),
                  tooltip: AppLocalizations.of(context).deleteAll,
                  onPressed: () => _showDeleteAllDialog(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const AppLoadingCenter();
          }

          if (state is NotificationError) {
            return Center(child: Text(AppMessages.resolve(context, state.message)));
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_off_outlined,
                        size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).noNotifications,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return Dismissible(
                  key: Key(notification.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Sil",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.delete, color: Colors.white),
                      ],
                    ),
                  ),
                  onDismissed: (direction) {
                    context
                        .read<NotificationCubit>()
                        .deleteNotification(notification.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Bildirim silindi"),
                          duration: Duration(seconds: 2)),
                    );
                  },
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    tileColor: notification.isRead
                        ? Colors.white
                        : AppColors.kPrimaryColor.withOpacity(0.1),
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.kPrimaryColor.withOpacity(0.2),
                      child: Icon(
                        notification.type == 'event'
                            ? Icons.event
                            : Icons.notifications,
                        color: AppColors.kPrimaryColor,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: AppColors.kTextColor,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notification.body),
                        const SizedBox(height: 4),
                        Text(
                          notification.timeAgo,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    onTap: () {
                      context
                          .read<NotificationCubit>()
                          .markAsRead(notification.id);
                    },
                    trailing: Icon(
                      Icons.chevron_left,
                      color: Colors.grey.withOpacity(0.3),
                      size: 20,
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteAll),
        content: Text(AppLocalizations.of(context).deleteAllConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationCubit>().clearAll();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text(AppLocalizations.of(context).allNotificationsDeleted)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context).deleteAll),
          ),
        ],
      ),
    );
  }
}

