import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/category_localizer.dart';
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
  OverlayEntry? _barrierEntry;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  @override
  void dispose() {
    _dismissBarrier();
    super.dispose();
  }

  Future<void> _checkUserRole() async {
    final isNgo = await EventRepository().isUserNgo();
    if (mounted) {
      setState(() {
        _isNgo = isNgo;
      });
    }
  }

  void _dismissBarrier() {
    _barrierEntry?.remove();
    _barrierEntry = null;
  }

  void _showConfirmSnackBar({
    required BuildContext context,
    required String message,
    required Color color,
    required VoidCallback onConfirm,
  }) {
    // Şeffaf bariyer: SnackBar dışına tıklanınca kapatsın
    _barrierEntry = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          _dismissBarrier();
        },
        child: const SizedBox.expand(),
      ),
    );
    Overlay.of(context).insert(_barrierEntry!);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: AppLocalizations.of(context).yes,
            textColor: Colors.white,
            onPressed: () {
              _dismissBarrier();
              onConfirm();
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final event = widget.event;
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toString();

    final formattedDate =
        DateFormat('d MMMM yyyy', localeName).format(event.date);
    final formattedTime = DateFormat('HH:mm').format(event.date);
    final dayName = DateFormat('EEEE', localeName).format(event.date);

    final bool isProject = (event.type == 'Proje');
    // Etkinlik/proje süresi doldu mu?
    final DateTime effectiveEndDate = event.endDate ?? event.date;
    final bool isExpired = effectiveEndDate.isBefore(DateTime.now());

    // Son başvuru tarihi doldu mu?
    final DateTime applyDeadline = event.lastApplyDate ?? event.date;
    final bool isApplyExpired = applyDeadline.isBefore(DateTime.now());

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
                              CategoryLocalizer.type(l10n, event.type)
                                  .toUpperCase(),
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
                              CategoryLocalizer.category(l10n, event.category),
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
                              color: AppColors.kPrimaryColor, size: 20),
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
                      if (event.lastApplyDate != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined,
                                color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.lastApplyPrefix(DateFormat(
                                        'd MMMM yyyy, HH:mm', localeName)
                                    .format(event.lastApplyDate!)),
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.orange.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                                    l10n.organizer,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  BlocBuilder<EventDetailCubit,
                                      EventDetailState>(
                                    builder: (context, state) {
                                      String orgName = l10n.loading;
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
                                  l10n.dateLabel,
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
                                  isProject
                                      ? l10n.applicationStat
                                      : l10n.participantStat,
                                  l10n.personCount(count),
                                  l10n.soFar,
                                  AppColors.kSecondaryColor);
                            },
                          )),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(l10n.details,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.kTextColor)),
                      const SizedBox(height: 12),
                      Text(
                        event.description,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.grey.shade600,
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
                            color: AppColors.kPrimaryColor, width: 2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.admin_panel_settings_outlined),
                        const SizedBox(width: 10),
                        Text(
                          l10n.manageApplications,
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
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_busy,
                            color: Colors.grey, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          l10n.eventExpired,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
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

              // Son başvuru süresi dolmuşsa ve başvuru yoksa
              if (isApplyExpired && applicationStatus == null) {
                return Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_off_outlined,
                            color: Colors.grey, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          l10n.applicationClosed,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              bool isFull = false;
              if (event.quota != null && event.quota! > 0) {
                isFull = currentCount >= event.quota!;
              }

              // Butonun aktif olup olmayacağı
              bool isButtonEnabled = applicationStatus != null || !isFull;

              // Duruma göre stil belirleme
              Color buttonColor = AppColors.kPrimaryColor;
              String buttonText = l10n.applyNow;
              IconData buttonIcon = Icons.send_rounded;

              if (applicationStatus == 'approved') {
                buttonColor = Colors.red;
                buttonText = l10n.leaveEvent;
                buttonIcon = Icons.exit_to_app_rounded;
              } else if (applicationStatus == 'pending') {
                buttonColor = Colors.orange;
                buttonText = l10n.applicationPending;
                buttonIcon = Icons.hourglass_empty_rounded;
              } else if (isFull) {
                buttonText = l10n.quotaFull;
                buttonIcon = Icons.lock_outline;
              }

              return SizedBox(
                height: 64,
                child: ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () {
                          final bool needsConfirmation =
                              applicationStatus == 'approved' ||
                                  applicationStatus == 'pending';

                          if (needsConfirmation) {
                            final String confirmMessage =
                                applicationStatus == 'approved'
                                    ? l10n.leaveEventConfirm
                                    : l10n.cancelApplicationConfirm;

                            _showConfirmSnackBar(
                              context: context,
                              message: confirmMessage,
                              color: buttonColor,
                              onConfirm: () =>
                                  context.read<EventDetailCubit>().toggleJoin(),
                            );
                          } else {
                            // İlk başvuru
                            if (isProject) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (dialogContext) {
                                  return _CoverLetterDialog(
                                    onConfirm: (coverLetter) {
                                      context
                                          .read<EventDetailCubit>()
                                          .toggleJoin(coverLetter: coverLetter);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l10n.applicationSubmitted,
                                            style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          backgroundColor: Colors.orange,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            } else {
                              context.read<EventDetailCubit>().toggleJoin();
                              if (applicationStatus == null && !isFull) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Başvurunuz iletildi, onay bekleniyor!',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    backgroundColor: Colors.orange,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    shadowColor:
                        (isButtonEnabled ? buttonColor : Colors.grey.shade400)
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

class _CoverLetterDialog extends StatefulWidget {
  final ValueChanged<String> onConfirm;

  const _CoverLetterDialog({required this.onConfirm});

  @override
  State<_CoverLetterDialog> createState() => _CoverLetterDialogState();
}

class _CoverLetterDialogState extends State<_CoverLetterDialog> {
  final TextEditingController _controller = TextEditingController();
  int _charCount = 0;
  final int _minLength = 50;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateCharCount);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCharCount);
    _controller.dispose();
    super.dispose();
  }

  void _updateCharCount() {
    setState(() {
      _charCount = _controller.text.trim().length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _charCount >= _minLength;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 16,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  color: AppColors.kPrimaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.intentLetter,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.projectLetterPrompt,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              minLines: 4,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.kTextColor,
              ),
              decoration: InputDecoration(
                hintText: l10n.letterHint,
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.kPrimaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                l10n.charCountLabel(_charCount, _minLength),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: isValid ? Colors.green : Colors.grey.shade500,
                  fontWeight: isValid ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isValid
                        ? () {
                            Navigator.pop(context);
                            widget.onConfirm(_controller.text.trim());
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kPrimaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: isValid ? 4 : 0,
                    ),
                    child: Text(
                      l10n.send,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
