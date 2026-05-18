import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gonullunet_app/models/event_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import '../../views/event_detail_page.dart';
import '../app_loading_indicator.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // --- TARİH FORMATLAMA ---
    String dateString = DateFormat('dd MMM', 'tr_TR').format(event.date);
    String timeString = DateFormat('HH:mm').format(event.date);

    // Tarih Aralığı Kontrolü
    if (event.endDate != null) {
      final bool isSameDay = event.date.year == event.endDate!.year &&
          event.date.month == event.endDate!.month &&
          event.date.day == event.endDate!.day;

      if (!isSameDay) {
        final String endDayString =
            DateFormat('dd MMM', 'tr_TR').format(event.endDate!);
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
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Proje için sol renkli şerit
              if (isProje)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 5,
                  child: Container(color: projeColor),
                ),
              Row(
                children: [
                  // --- SOL: GÖRSEL ---
                  _buildImage(context),

                  // --- SAĞ: BİLGİLER ---
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Üst kısım: Tarih + Tip etiketi
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 13,
                                color: AppColors.kPrimaryColor,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  dateString.length > 15
                                      ? dateString
                                      : '$dateString • $timeString',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.kPrimaryColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isProje)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D7377),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.work_rounded,
                                          size: 10, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        "PROJE",
                                        style: TextStyle(
                                          fontSize: 9,
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
                            style: const TextStyle(
                              fontSize: 15,
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
                                  size: 14, color: Colors.grey.shade400),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  event.location,
                                  style: TextStyle(
                                    fontSize: 12,
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isFull
                                        ? Colors.red.withOpacity(0.08)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isFull ? "Dolu" : quotaText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isFull
                                          ? Colors.red
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
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
          Icon(placeholderIcon, color: Colors.white.withOpacity(0.9), size: 36),
          const SizedBox(height: 6),
          Text(
            event.category,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 10,
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
            child: const Center(child: AppLoadingIndicator(size: 28)),
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
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
      child: SizedBox(
        width: 120,
        height: 140,
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
        "İlk sen ol!",
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 11,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    const int maxAvatars = 3;
    final int displayCount =
        participants.length > maxAvatars ? maxAvatars : participants.length;
    final int remainingCount = participants.length - maxAvatars;

    return SizedBox(
      height: 24,
      width: 24.0 + (displayCount - 1) * 12 + (remainingCount > 0 ? 22 : 0),
      child: Stack(
        children: [
          for (int i = 0; i < displayCount; i++)
            Positioned(
              left: i * 12.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 11,
                  backgroundColor: Colors.grey.shade100,
                  child:
                      Icon(Icons.person, size: 12, color: Colors.grey.shade400),
                ),
              ),
            ),
          if (remainingCount > 0)
            Positioned(
              left: displayCount * 12.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 11,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                      fontSize: 8,
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
