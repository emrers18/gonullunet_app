import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gonullunet_app/models/event_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import '../../views/event_detail_page.dart';

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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // --- SOL: GÖRSEL ---
            _buildImage(),

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
                        if (event.type == 'Proje')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "PROJE",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                                letterSpacing: 0.5,
                              ),
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
                        color: AppColors.primaryText,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Konum
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Color(0xFFBDBDBD)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
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
                        _buildParticipantsRow(event.participants),
                        const Spacer(),
                        if (quotaText.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isFull
                                  ? Colors.red.withOpacity(0.08)
                                  : Colors.grey.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isFull ? "Dolu" : quotaText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isFull
                                    ? Colors.red[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
      child: SizedBox(
        width: 120,
        height: 140,
        child: Stack(
          fit: StackFit.expand,
          children: [
            event.imageUrl.isNotEmpty
                ? Image.network(
                    event.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress
                                            .cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                            color: AppColors.kPrimaryColor,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.grey[100],
                      child: Icon(Icons.image_not_supported_outlined,
                          color: Colors.grey[300], size: 28),
                    ),
                  )
                : Container(
                    color: Colors.grey[100],
                    child: Icon(Icons.event_rounded,
                        color: Colors.grey[300], size: 32),
                  ),
            // Subtle gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.black.withOpacity(0.08),
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

  Widget _buildParticipantsRow(List<dynamic> participants) {
    if (participants.isEmpty) {
      return Text(
        "İlk sen ol!",
        style: TextStyle(
          color: Colors.grey[400],
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
                child: const CircleAvatar(
                  radius: 11,
                  backgroundColor: Color(0xFFE8E8E8),
                  child: Icon(Icons.person, size: 12, color: Colors.white),
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
                  backgroundColor: const Color(0xFFF0F0F0),
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
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
