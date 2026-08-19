import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/models/ngo_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';
import 'package:gonullunet_app/utils/responsive.dart';

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
        borderRadius: BorderRadius.circular(Responsive.scale(context, 28)),
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
          borderRadius: BorderRadius.circular(Responsive.scale(context, 28)),
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
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(Responsive.scale(context, 28))),
                        child: Hero(
                          tag: 'ngo_image_${ngo.id}',
                          child: CachedNetworkImage(
                            imageUrl: ngo.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade50,
                              child: Center(
                                  child: AppLoadingIndicator(
                                      size: Responsive.scale(context, 28))),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade100,
                              child: Icon(Icons.business,
                                  size: Responsive.scale(context, 40),
                                  color: Colors.grey.shade400),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Gradient Overlay for Depth
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(Responsive.scale(context, 28))),
                          gradient: const LinearGradient(
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
                      top: Responsive.scale(context, 12),
                      right: Responsive.scale(context, 12),
                      child: FutureBuilder<int>(
                        future: context
                            .read<NgoRepository>()
                            .getNgoEventCount(ngo.id),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return Container(
                            padding: Responsive.padding(context,
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius:
                                  BorderRadius.circular(Responsive.scale(context, 12)),
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
                                Icon(Icons.auto_awesome,
                                    size: Responsive.scale(context, 12),
                                    color: AppColors.kPrimaryColor),
                                SizedBox(width: Responsive.scale(context, 4)),
                                Text(
                                  '$count',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: Responsive.sp(context, 12),
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
                  padding: Responsive.padding(context, all: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kurum Adı
                      Text(
                        ngo.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: Responsive.sp(context, 15),
                          fontWeight: FontWeight.w800,
                          color: AppColors.kTextColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: Responsive.scale(context, 6)),

                      // Şehir / Konum
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: Responsive.scale(context, 14),
                              color: AppColors.kPrimaryColor.withOpacity(0.8)),
                          SizedBox(width: Responsive.scale(context, 4)),
                          Expanded(
                            child: Text(
                              ngo.location.isNotEmpty
                                  ? ngo.location
                                  : AppLocalizations.of(context)
                                      .locationUnspecified,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: Responsive.sp(context, 12),
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.scale(context, 10)),

                      // Kısa Açıklama
                      Expanded(
                        child: Text(
                          ngo.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: Responsive.sp(context, 12),
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
                            AppLocalizations.of(context).examine,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: Responsive.sp(context, 11),
                              color: AppColors.kPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: Responsive.scale(context, 2)),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: Responsive.scale(context, 10),
                              color: AppColors.kPrimaryColor),
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
