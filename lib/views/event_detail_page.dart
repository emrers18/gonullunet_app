import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../logic/event_detail_cubit.dart';
import '../logic/event_detail_state.dart';
import '../models/event_model.dart';
import '../repo/event_repository.dart';
import '../repo/notification_repository.dart';
import '../widgets/events/build_glass_button_widget.dart';
import '../widgets/events/build_info_card_widget.dart';
import 'manage_applications_page.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventDetailCubit(EventRepository(), event),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _EventBody(event: event),
      ),
    );
  }
}

class _EventBody extends StatefulWidget {
  final Event event;

  const _EventBody({required this.event});

  @override
  State<_EventBody> createState() => _EventBodyState();
}

class _EventBodyState extends State<_EventBody> {
  bool _isNgo = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final isNgo = await EventRepository().isUserNgo();
    if (mounted) {
      setState(() {
        _isNgo = isNgo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final event = widget.event;

    final formattedDate = DateFormat('d MMMM yyyy', 'tr_TR').format(event.date);
    final formattedTime = DateFormat('HH:mm').format(event.date);
    final dayName = DateFormat('EEEE', 'tr_TR').format(event.date);

    final bool isProject = (event.type == 'Proje');
    // Etkinlik/proje süresi doldu mu?
    final DateTime effectiveEndDate = event.endDate ?? event.date;
    final bool isExpired = effectiveEndDate.isBefore(DateTime.now());

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: size.height * 0.45,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: event.imageUrl.isNotEmpty
                    ? CachedNetworkImageProvider(event.imageUrl)
                    : const AssetImage('lib/assets/images/logo.png')
                        as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.38),
                Container(
                  constraints: BoxConstraints(minHeight: size.height * 0.62),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(40)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 40,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(24, 40, 24, _isNgo ? 40 : 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.kPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              event.type.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.kPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              event.category,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        event.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kTextColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppColors.kPrimaryColor,
                              size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              child: Icon(Icons.business),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Düzenleyen",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  BlocBuilder<EventDetailCubit,
                                      EventDetailState>(
                                    builder: (context, state) {
                                      String orgName = "Yükleniyor...";
                                      if (state is EventDetailLoaded) {
                                        orgName = state.organizerName;
                                      } else if (state is EventDetailUpdated) {
                                        orgName = state.organizerName;
                                      }
                                      return Text(
                                        orgName,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.kTextColor,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                              child: buildInfoCard(
                                  context,
                                  Icons.calendar_month,
                                  "Tarih",
                                  formattedDate,
                                  "$dayName, $formattedTime",
                                  AppColors.kPrimaryColor)),
                          const SizedBox(width: 16),
                          Expanded(child:
                              BlocBuilder<EventDetailCubit, EventDetailState>(
                            builder: (context, state) {
                              int count = event.participants.length;
                              if (state is EventDetailLoaded) {
                                count = state.participantCount;
                              } else if (state is EventDetailUpdated) {
                                count = state.participantCount;
                              }
                              return buildInfoCard(
                                  context,
                                  Icons.group,
                                  isProject ? "Başvuru" : "Katılımcı",
                                  "$count Kişi",
                                  "Şimdiye kadar",
                                  AppColors.kSecondaryColor);
                            },
                          )),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text("Detaylar",
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.kTextColor)),
                      const SizedBox(height: 12),
                      Text(
                        event.description,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color:
                                Colors.grey.shade600,
                            height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildGlassButton(
                      Icons.arrow_back, () => Navigator.pop(context)),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: BlocBuilder<EventDetailCubit, EventDetailState>(
            builder: (context, state) {
              final currentUser = FirebaseAuth.instance.currentUser;

              if (currentUser != null && event.organizerId == currentUser.uid) {
                return SizedBox(
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RepositoryProvider(
                            create: (context) => NotificationRepository(),
                            child: ManageApplicationsPage(
                              eventId: event.id,
                              eventTitle: event.title,
                            ),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.kPrimaryColor,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                            color: AppColors.kPrimaryColor,
                            width: 2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.admin_panel_settings_outlined),
                        const SizedBox(width: 10),
                        Text(
                          "Başvuruları Yönet",
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (_isNgo) {
                return const SizedBox.shrink();
              }

              // --- Süresi dolmuşsa buton gösterme ---
              if (isExpired) {
                return Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_busy,
                            color:
                                Colors.grey,
                            size: 22),
                        const SizedBox(width: 10),
                        Text(
                          "Bu etkinliğin süresi doldu",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              String? applicationStatus;
              int currentCount = event.participants.length;

              if (state is EventDetailLoaded) {
                applicationStatus = state.applicationStatus;
                currentCount = state.participantCount;
              } else if (state is EventDetailUpdated) {
                applicationStatus = state.applicationStatus;
                currentCount = state.participantCount;
              }

              bool isFull = false;
              if (event.quota != null && event.quota! > 0) {
                isFull = currentCount >= event.quota!;
              }

              // Butonun aktif olup olmayacağı
              bool isButtonEnabled = applicationStatus != null || !isFull;

              // Duruma göre stil belirleme
              Color buttonColor = AppColors.kPrimaryColor;
              String buttonText = "Hemen Başvur";
              IconData buttonIcon = Icons.send_rounded;

              if (applicationStatus == 'approved') {
                buttonColor = Colors.red;
                buttonText = "Etkinlikten Ayrıl";
                buttonIcon = Icons.exit_to_app_rounded;
              } else if (applicationStatus == 'pending') {
                buttonColor = Colors.orange;
                buttonText = "Başvuru Bekleniyor (İptal)";
                buttonIcon = Icons.hourglass_empty_rounded;
              } else if (isFull) {
                buttonText = "Kontenjan Dolu";
                buttonIcon = Icons.lock_outline;
              }

              return SizedBox(
                height: 64,
                child: ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () {
                          context.read<EventDetailCubit>().toggleJoin();

                          if (applicationStatus == null && !isFull) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Başvurunuz iletildi, onay bekleniyor!"),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    shadowColor: (isButtonEnabled
                            ? buttonColor
                            : Colors.grey.shade400)
                        .withOpacity(0.4),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(buttonIcon),
                      const SizedBox(width: 10),
                      Text(
                        buttonText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

