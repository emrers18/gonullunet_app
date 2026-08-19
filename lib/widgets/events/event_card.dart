import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/models/event_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/category_localizer.dart';
import 'package:gonullunet_app/utils/responsive.dart';
import '../../views/event_detail_page.dart';
import '../app_loading_indicator.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toString();
    // --- TARİH FORMATLAMA ---
    String dateString = DateFormat('dd MMM', localeName).format(event.date);
    String timeString = DateFormat('HH:mm').format(event.date);

    // Tarih Aralığı Kontrolü
    if (event.endDate != null) {
      final bool isSameDay = event.date.year == event.endDate!.year &&
          event.date.month == event.endDate!.month &&
          event.date.day == event.endDate!.day;

      if (!isSameDay) {
        final String endDayString =
            DateFormat('dd MMM', localeName).format(event.endDate!);
        dateString = "$dateString - $endDayString";
      }
    }

    // Kontenjan Bilgisi
    bool isFull = false;
    String quotaText = "";
    if (event.quota != null && event.quota! > 0) {
      isFull = event.participants.length >= event.quota!;
      quotaText = "${event.participants.length}/${event.quota}";
    }

    final bool isProje = event.type == 'Proje';
    // Proje rengi: koyu teal/mavi-yeşil
    const Color projeColor = Color(0xFF00949F);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(event: event),
          ),
        );
      },
      child: Container(
        height: Responsive.scale(context, 140),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.scale(context, 20)),
          border: Border.all(
            color: isProje ? projeColor.withOpacity(0.4) : Colors.grey.shade200,
            width: isProje ? 1.2 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isProje
                  ? projeColor.withOpacity(0.12)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Responsive.scale(context, 20)),
          child: Stack(
            children: [
              // Proje için sol renkli şerit
              if (isProje)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: Responsive.scale(context, 5),
                  child: Container(color: projeColor),
                ),
              Row(
                children: [
                  // --- SOL: GÖRSEL ---
                  _buildImage(context),

                  // --- SAĞ: BİLGİLER ---
                  Expanded(
                    child: Padding(
                      padding: Responsive.padding(context,
                          horizontal: 14, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Üst kısım: Tarih + Tip etiketi
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: Responsive.scale(context, 13),
                                color: AppColors.kPrimaryColor,
                              ),
                              SizedBox(width: Responsive.scale(context, 4)),
                              Expanded(
                                child: Text(
                                  dateString.length > 15
                                      ? dateString
                                      : '$dateString • $timeString',
                                  style: TextStyle(
                                    fontSize: Responsive.sp(context, 12),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.kPrimaryColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isProje)
                                Container(
                                  padding: Responsive.padding(context,
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D7377),
                                    borderRadius: BorderRadius.circular(
                                        Responsive.scale(context, 8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.work_rounded,
                                          size: Responsive.scale(context, 10),
                                          color: Colors.white),
                                      SizedBox(
                                          width: Responsive.scale(context, 4)),
                                      Text(
                                        l10n.typeProject.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: Responsive.sp(context, 9),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          // Başlık
                          Text(
                            event.title,
                            style: TextStyle(
                              fontSize: Responsive.sp(context, 15),
                              fontWeight: FontWeight.bold,
                              color: AppColors.kTextColor,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Konum
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: Responsive.scale(context, 14),
                                  color: Colors.grey.shade400),
                              SizedBox(width: Responsive.scale(context, 3)),
                              Expanded(
                                child: Text(
                                  event.location,
                                  style: TextStyle(
                                    fontSize: Responsive.sp(context, 12),
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          // Alt kısım: Katılımcılar + Kontenjan
                          Row(
                            children: [
                              _buildParticipantsRow(
                                  context, event.participants),
                              const Spacer(),
                              if (quotaText.isNotEmpty)
                                Container(
                                  padding: Responsive.padding(context,
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isFull
                                        ? Colors.red.withOpacity(0.08)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(
                                        Responsive.scale(context, 8)),
                                  ),
                                  child: Text(
                                    isFull ? l10n.eventFull : quotaText,
                                    style: TextStyle(
                                      fontSize: Responsive.sp(context, 11),
                                      fontWeight: FontWeight.w600,
                                      color: isFull
                                          ? Colors.red
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              SizedBox(width: Responsive.scale(context, 6)),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: Responsive.scale(context, 20),
                                color: Colors.grey.shade400.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    // Kategoriye göre placeholder renk paleti
    final Color placeholderColor = _categoryColor(event.category);
    final IconData placeholderIcon = _categoryIcon(event.category);

    Widget placeholder = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            placeholderColor.withOpacity(0.85),
            placeholderColor.withOpacity(0.55),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(placeholderIcon,
              color: Colors.white.withOpacity(0.9),
              size: Responsive.scale(context, 36)),
          SizedBox(height: Responsive.scale(context, 6)),
          Text(
            CategoryLocalizer.category(AppLocalizations.of(context),
                event.category),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: Responsive.sp(context, 10),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    Widget imageWidget;
    if (event.imageUrl.isNotEmpty) {
      // ignore: avoid_print
      debugPrint('[EventCard] imageUrl: ${event.imageUrl}');
      imageWidget = Image.network(
        event.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  placeholderColor.withOpacity(0.4),
                  placeholderColor.withOpacity(0.2),
                ],
              ),
            ),
            child: Center(
                child: AppLoadingIndicator(
                    size: Responsive.scale(context, 28))),
          );
        },
        errorBuilder: (c, e, s) {
          debugPrint('[EventCard] Resim yüklenemedi: $e | URL: ${event.imageUrl}');
          return placeholder;
        },
      );
    } else {
      imageWidget = placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.horizontal(
          left: Radius.circular(Responsive.scale(context, 20))),
      child: SizedBox(
        width: Responsive.scale(context, 120),
        height: Responsive.scale(context, 140),
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageWidget,
            // Subtle right-edge gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kategoriye göre renk
  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'çevre':
        return const Color(0xFF2E7D32);
      case 'eğitim':
        return const Color(0xFF1565C0);
      case 'sağlık':
        return const Color(0xFFC62828);
      case 'hayvan':
      case 'hayvanlar':
        return const Color(0xFF6A1B9A);
      case 'sosyal':
        return const Color(0xFF00838F);
      case 'spor':
        return const Color(0xFFE65100);
      case 'kültür':
      case 'sanat':
        return const Color(0xFF4527A0);
      case 'teknoloji':
        return const Color(0xFF0277BD);
      default:
        return const Color(0xFF455A64);
    }
  }

  /// Kategoriye göre ikon
  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'çevre':
        return Icons.eco_rounded;
      case 'eğitim':
        return Icons.school_rounded;
      case 'sağlık':
        return Icons.favorite_rounded;
      case 'hayvan':
      case 'hayvanlar':
        return Icons.pets_rounded;
      case 'sosyal':
        return Icons.people_rounded;
      case 'spor':
        return Icons.sports_soccer_rounded;
      case 'kültür':
      case 'sanat':
        return Icons.palette_rounded;
      case 'teknoloji':
        return Icons.computer_rounded;
      default:
        return Icons.volunteer_activism_rounded;
    }
  }

  Widget _buildParticipantsRow(
      BuildContext context, List<dynamic> participants) {
    if (participants.isEmpty) {
      return Text(
        AppLocalizations.of(context).beFirstToJoin,
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: Responsive.sp(context, 11),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    const int maxAvatars = 3;
    final int displayCount =
        participants.length > maxAvatars ? maxAvatars : participants.length;
    final int remainingCount = participants.length - maxAvatars;

    final double avatarStep = Responsive.scale(context, 12);
    final double avatarSlot = Responsive.scale(context, 24);
    final double overflowSlot =
        remainingCount > 0 ? Responsive.scale(context, 22) : 0;

    return SizedBox(
      height: avatarSlot,
      width: avatarSlot + (displayCount - 1) * avatarStep + overflowSlot,
      child: Stack(
        children: [
          for (int i = 0; i < displayCount; i++)
            Positioned(
              left: i * avatarStep,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: Responsive.scale(context, 11),
                  backgroundColor: Colors.grey.shade100,
                  child: Icon(Icons.person,
                      size: Responsive.scale(context, 12),
                      color: Colors.grey.shade400),
                ),
              ),
            ),
          if (remainingCount > 0)
            Positioned(
              left: displayCount * avatarStep,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: Responsive.scale(context, 11),
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 8),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
