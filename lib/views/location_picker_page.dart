import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;

import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
import 'package:gonullunet_app/widgets/app_loading_indicator.dart';
import '../logic/location_cubit.dart';
import '../logic/location_state.dart';
import '../utils/responsive.dart';

class LocationPickerPage extends StatelessWidget {
  const LocationPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationCubit()..getCurrentLocation(),
      child: const LocationPickerView(),
    );
  }
}

class LocationPickerView extends StatefulWidget {
  const LocationPickerView({super.key});

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  bool _isCameraMoving = false;

  static const LatLng _defaultLocation = LatLng(41.0082, 28.9784);

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<LocationCubit, LocationState>(
        listener: (context, state) {
          if (state is LocationLoaded && state.shouldMoveCamera) {
            _mapController.move(state.location, 15.0);
          } else if (state is LocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppMessages.resolve(context, state.message)),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Stack(
          children: [
            // 1. KATMAN: HARİTA
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultLocation,
                initialZoom: 15.0,
                onMapEvent: (event) {
                  if (event is MapEventMoveStart) {
                    setState(() => _isCameraMoving = true);
                  } else if (event is MapEventMoveEnd ||
                      event is MapEventFlingAnimationEnd) {
                    setState(() {
                      _isCameraMoving = false;
                    });
                    context
                        .read<LocationCubit>()
                        .onCameraIdle(_mapController.camera.center);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.gonullunet.gonullunet_app',
                ),
              ],
            ),

            // 2. KATMAN: ORTADAKİ SABİT PİN (PREMIUM TASARIM)
            Center(
              child: Padding(
                padding: Responsive.padding(context, bottom: 40.0),
                child: AnimatedScale(
                  scale: _isCameraMoving ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: Responsive.scale(context, 44),
                        height: Responsive.scale(context, 44),
                        decoration: BoxDecoration(
                          color: AppColors.kPrimaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.kPrimaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: Responsive.scale(context, 24),
                        ),
                      ),
                      // Pin tail
                      CustomPaint(
                        size: Size(Responsive.scale(context, 12), Responsive.scale(context, 10)),
                        painter:
                            const _PinTailPainter(color: AppColors.kPrimaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. KATMAN: ÜST ARAMA ÇUBUĞU (EVENTS MAP PAGE STİLİ)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + Responsive.scale(context, 10),
                    bottom: Responsive.scale(context, 20),
                    left: Responsive.scale(context, 16),
                    right: Responsive.scale(context, 16)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    _buildCircleButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    SizedBox(width: Responsive.scale(context, 12)),
                    Expanded(
                      child: Container(
                        height: Responsive.scale(context, 48),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(Responsive.scale(context, 30)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) {
                            context.read<LocationCubit>().searchLocation(value);
                            FocusScope.of(context).unfocus();
                          },
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: Responsive.sp(context, 14),
                            color: AppColors.primaryText,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context).searchLocationHint,
                            hintStyle: TextStyle(
                                color: AppColors.textSub, fontSize: Responsive.sp(context, 14)),
                            prefixIcon: Icon(Icons.search,
                                color: AppColors.textSub, size: Responsive.scale(context, 20)),
                            border: InputBorder.none,
                            contentPadding:
                                Responsive.padding(context, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. KATMAN: KONUMUMA GİT BUTONU
            Positioned(
              bottom: Responsive.scale(context, 200),
              right: Responsive.scale(context, 16),
              child: _buildCircleButton(
                icon: Icons.my_location,
                onTap: () => context.read<LocationCubit>().getCurrentLocation(),
                size: Responsive.scale(context, 50),
              ),
            ),

            // 5. KATMAN: ALT ONAY PANELİ
            Positioned(
              bottom: Responsive.scale(context, 20),
              left: Responsive.scale(context, 16),
              right: Responsive.scale(context, 16),
              child: Container(
                padding: Responsive.padding(context, all: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Responsive.scale(context, 24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: BlocBuilder<LocationCubit, LocationState>(
                  builder: (context, state) {
                    final l10n = AppLocalizations.of(context);
                    String displayAddress = l10n.selectingLocation;
                    LatLng? confirmCoordinates;
                    bool isLoading = false;

                    if (state is LocationLoaded) {
                      displayAddress =
                          AppMessages.resolve(context, state.address);
                      confirmCoordinates = state.location;
                    } else if (state is LocationLoading) {
                      displayAddress = l10n.addressFinding;
                      isLoading = true;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: Responsive.padding(context, all: 8),
                              decoration: BoxDecoration(
                                color: AppColors.kPrimaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.place_rounded,
                                color: AppColors.kPrimaryColor,
                                size: Responsive.scale(context, 20),
                              ),
                            ),
                            SizedBox(width: Responsive.scale(context, 12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.selectedAddress,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.grey[500],
                                      fontSize: Responsive.sp(context, 11),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: Responsive.scale(context, 2)),
                                  Text(
                                    displayAddress,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: Responsive.sp(context, 14),
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.scale(context, 20)),
                        ElevatedButton(
                          onPressed: (confirmCoordinates == null || isLoading)
                              ? null
                              : () {
                                  Navigator.pop(context, {
                                    'geoPoint': confirmCoordinates,
                                    'address': displayAddress,
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kPrimaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[200],
                            elevation: 0,
                            padding: Responsive.padding(context, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: Responsive.scale(context, 20),
                                  width: Responsive.scale(context, 20),
                                  child: AppLoadingIndicator(size: Responsive.scale(context, 20)),
                                )
                              : Text(
                                  l10n.confirmLocation,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: Responsive.sp(context, 16),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(
      {required IconData icon, required VoidCallback onTap, double size = 48}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primaryText, size: Responsive.scale(context, 22)),
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  const _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter oldDelegate) =>
      color != oldDelegate.color;
}
