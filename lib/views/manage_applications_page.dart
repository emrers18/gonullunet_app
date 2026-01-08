import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/utils/app_colors.dart';

import '../logic/manage_applications_cubit.dart';
import '../logic/manage_applications_state.dart';
import '../repo/event_repository.dart';
import '../repo/notification_repository.dart';

class ManageApplicationsPage extends StatelessWidget {
  final String eventId;
  final String eventTitle;

  const ManageApplicationsPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManageApplicationsCubit(
        eventRepository: context.read<EventRepository>(),
        notificationRepo: context.read<NotificationRepository>(),
        eventId: eventId,
        eventTitle: eventTitle,
      )..loadApplications(),
      child: const ManageApplicationsView(),
    );
  }
}

class ManageApplicationsView extends StatelessWidget {
  const ManageApplicationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Başvurular",
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: BlocBuilder<ManageApplicationsCubit, ManageApplicationsState>(
        builder: (context, state) {
          if (state is ManageApplicationsLoading) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryColor));
          }
          if (state is ManageApplicationsError) {
            return Center(child: Text(state.message));
          }
          if (state is ManageApplicationsLoaded) {
            if (state.applications.isEmpty) {
              return const Center(child: Text("Henüz başvuru yok."));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.applications.length,
              separatorBuilder: (ctx, i) => const Divider(),
              itemBuilder: (context, index) {
                final app = state.applications[index];

                // Duruma göre ikon ve renk
                Color statusColor = Colors.orange;
                IconData statusIcon = Icons.access_time;
                String statusText = "Bekliyor";

                if (app.status == 'approved') {
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  statusText = "Onaylandı";
                } else if (app.status == 'rejected') {
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  statusText = "Reddedildi";
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (app.userImageUrl != null &&
                            app.userImageUrl!.isNotEmpty)
                        ? NetworkImage(app.userImageUrl!)
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: (app.userImageUrl == null)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    "${app.userName ?? 'İsimsiz'} ${app.userSurname ?? ''}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(statusText,
                          style: TextStyle(color: statusColor, fontSize: 12)),
                      const SizedBox(width: 10),
                      Text(app.timeAgo, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: app.status == 'pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                context
                                    .read<ManageApplicationsCubit>()
                                    .updateStatus(app, 'approved');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                context
                                    .read<ManageApplicationsCubit>()
                                    .updateStatus(app, 'rejected');
                              },
                            ),
                          ],
                        )
                      : null, // Onaylandıysa veya reddedildiyse buton gösterme
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
