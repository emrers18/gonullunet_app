import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/models/ngo_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';

import 'package:gonullunet_app/repo/ngo_repository.dart';
import '../../views/ngo_detail_page.dart';

class NgoCard extends StatelessWidget {
  final Ngo ngo;

  const NgoCard({
    super.key,
    required this.ngo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NgoDetailPage(ngo: ngo),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Logo Alanı (Stack ile yüzen badge) ---
              Expanded(
                flex: 12,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28)),
                        child: Hero(
                          tag: 'ngo_image_${ngo.id}',
                          child: CachedNetworkImage(
                            imageUrl: ngo.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade50,
                              child: const Center(child: AppLoadingIndicator(size: 28)),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade100,
                              child: Icon(Icons.business,
                                  size: 40, color: Colors.grey.shade400),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Gradient Overlay for Depth
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black12,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Etkinlik Sayısı Floating Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: FutureBuilder<int>(
                        future: context
                            .read<NgoRepository>()
                            .getNgoEventCount(ngo.id),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome,
                                    size: 12, color: AppColors.kPrimaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  '$count',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.kTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // --- Bilgi Alanı ---
              Expanded(
                flex: 11,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kurum Adı
                      Text(
                        ngo.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.kTextColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // Şehir / Konum
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 14,
                              color: AppColors.kPrimaryColor.withOpacity(0.8)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ngo.location.isNotEmpty ? ngo.location : 'Lokasyon Belirtilmemiş',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Kısa Açıklama
                      Expanded(
                        child: Text(
                          ngo.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ),
                      
                      // View Profile Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'İncele',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.kPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              size: 10, color: AppColors.kPrimaryColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
