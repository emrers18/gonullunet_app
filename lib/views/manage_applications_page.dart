import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/utils/app_colors.dart';

import '../logic/manage_applications_cubit.dart';
import '../logic/manage_applications_state.dart';
import '../models/application_model.dart';
import '../repo/event_repository.dart';
import '../utils/gamification_utils.dart';

import 'applicant_profile_page.dart';

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
        eventId: eventId,
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
      backgroundColor: const Color(0xFFF8F6F5),
      appBar: AppBar(
        title: Text(
          "Başvurular",
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF181210),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F6F5).withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF181210)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<ManageApplicationsCubit, ManageApplicationsState>(
        builder: (context, state) {
          if (state is ManageApplicationsLoading) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.kPrimaryColor));
          }
          if (state is ManageApplicationsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: Colors.red.shade300),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is ManageApplicationsLoaded) {
            if (state.applications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      "Henüz başvuru yok.",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.applications.length,
              itemBuilder: (context, index) {
                final app = state.applications[index];
                return _ApplicationCard(app: app);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel app;

  const _ApplicationCard({required this.app});

  @override
  Widget build(BuildContext context) {
    // Status styling
    Color statusColor;
    IconData statusIcon;
    String statusText;
    Color statusBg;

    switch (app.status) {
      case 'approved':
        statusColor = const Color(0xFF16A34A);
        statusIcon = Icons.check_circle_rounded;
        statusText = "Onaylandı";
        statusBg = const Color(0xFFDCFCE7);
        break;
      case 'rejected':
        statusColor = const Color(0xFFDC2626);
        statusIcon = Icons.cancel_rounded;
        statusText = "Reddedildi";
        statusBg = const Color(0xFFFEE2E2);
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.schedule_rounded;
        statusText = "Bekliyor";
        statusBg = const Color(0xFFFEF3C7);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ApplicantProfilePage(userId: app.userId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Row: Avatar + Name + Status
            Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06), blurRadius: 6),
                    ],
                    image: (app.userImageUrl != null &&
                            app.userImageUrl!.isNotEmpty)
                        ? DecorationImage(
                            image:
                                CachedNetworkImageProvider(app.userImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (app.userImageUrl == null || app.userImageUrl!.isEmpty)
                      ? Center(
                          child: Text(
                            _getInitials(app.userName, app.userSurname),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.kPrimaryColor,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Name & time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${app.userName ?? 'İsimsiz'} ${app.userSurname ?? ''}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF181210),
                        ),
                      ),
                      if (app.xp != null) ...[
                        const SizedBox(height: 4),
                        _buildLevelBadge(app.xp!),
                      ],
                      const SizedBox(height: 3),
                      Text(
                        app.timeAgo,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF8D6A5E),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Bottom Row: Action buttons or profile link
            if (app.status == 'pending') ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFF0EDED)),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Profili Gör
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ApplicantProfilePage(userId: app.userId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_outline, size: 18),
                      label: Text(
                        "Profili Gör",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Reddet
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context
                            .read<ManageApplicationsCubit>()
                            .updateStatus(app, 'rejected');
                      },
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: Text(
                        "Reddet",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: BorderSide(color: Colors.red.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Onayla
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<ManageApplicationsCubit>()
                            .updateStatus(app, 'approved');
                      },
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(
                        "Onayla",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getInitials(String? name, String? surname) {
    final n = (name != null && name.isNotEmpty) ? name[0].toUpperCase() : '';
    final s =
        (surname != null && surname.isNotEmpty) ? surname[0].toUpperCase() : '';
    if (n.isEmpty && s.isEmpty) return '?';
    return '$n$s';
  }

  Widget _buildLevelBadge(int xp) {
    final level = GamificationUtils.getLevelInfo(xp);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: level.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: level.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars, size: 12, color: level.color),
          const SizedBox(width: 4),
          Text(
            level.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: level.color,
            ),
          ),
        ],
      ),
    );
  }
}
