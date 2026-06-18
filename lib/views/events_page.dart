import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
import 'package:gonullunet_app/models/event_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/widgets/events/event_card.dart';
import 'package:gonullunet_app/widgets/events/add_event_modal.dart';

import '../logic/event_cubit.dart';
import '../logic/event_state.dart';
import '../widgets/events/event_filter_modal.dart';
import '../widgets/app_loading_indicator.dart';
import 'events_map_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final ScrollController _scrollController = ScrollController();
  static const LatLng _defaultLocation = LatLng(41.0082, 28.9784);

  @override
  void initState() {
    super.initState();
    context.read<EventCubit>().loadEvents();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final state = context.read<EventCubit>().state;
        if (state is EventLoaded && state.hasMore) {
          context.read<EventCubit>().loadEvents();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showAddEventModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddEventModal(),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<EventCubit>(),
          child: const EventFilterModal(),
        );
      },
    );
  }

  void _openFullMap(List<Event> events) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventsMapPage(events: events),
      ),
    );
  }

  // ---------- MİNİ HARİTA ----------

  Widget _buildMiniMap(List<Event> events) {
    final eventsWithLocation = events.where((e) => e.geoPoint != null).toList();

    final center = eventsWithLocation.isNotEmpty
        ? LatLng(
            eventsWithLocation.first.geoPoint!.latitude,
            eventsWithLocation.first.geoPoint!.longitude,
          )
        : _defaultLocation;

    final markers = eventsWithLocation.map((e) {
      return Marker(
        point: LatLng(e.geoPoint!.latitude, e.geoPoint!.longitude),
        width: 36,
        height: 44,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.kPrimaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.kPrimaryColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.event_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
            const CustomPaint(
              size: Size(10, 8),
              painter: _MiniPinTailPainter(color: AppColors.kPrimaryColor),
            ),
          ],
        ),
      );
    }).toList();

    return GestureDetector(
      onTap: () => _openFullMap(eventsWithLocation),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Harita
              FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 11.5,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.gonullunet.gonullunet_app',
                  ),
                  if (markers.isNotEmpty) MarkerLayer(markers: markers),
                ],
              ),

              // Hafif üst gradient overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Alt gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 70,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Üst sağ: Genişlet etiketi
              Positioned(
                top: 12,
                right: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.open_in_full_rounded,
                            size: 14,
                            color: eventsWithLocation.isNotEmpty
                                ? AppColors.kPrimaryColor
                                : Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            AppLocalizations.of(context).fullScreen,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: eventsWithLocation.isNotEmpty
                                  ? AppColors.primaryText
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Alt sol: Etkinlik sayısı rozeti
              Positioned(
                bottom: 12,
                left: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimaryColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            '${eventsWithLocation.length} etkinlik haritada',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Tam ekran dokunma katmanı (FlutterMap gesture'ı tükettiği için
              // üste şeffaf bir katman koyuyoruz)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _openFullMap(eventsWithLocation),
                  behavior: HitTestBehavior.translucent,
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- BODY ----------

  Widget _buildBody(BuildContext context, EventState state) {
    if (state is EventLoading && state.isFirstFetch) {
      return const AppLoadingCenter();
    }

    if (state is EventError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                AppMessages.resolve(context, state.message),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 15),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.read<EventCubit>().refresh(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Tekrar Dene"),
              ),
            ],
          ),
        ),
      );
    }

    final List<dynamic> events;
    final bool hasMore;

    if (state is EventLoaded) {
      events = state.events;
      hasMore = state.hasMore;
    } else if (state is EventLoading && !state.isFirstFetch) {
      events = state.oldEvents;
      hasMore = true;
    } else {
      return const SizedBox.shrink();
    }

    final typedEvents = events.whereType<Event>().toList();

    return RefreshIndicator(
      onRefresh: () => context.read<EventCubit>().refresh(),
      color: const Color(0xFF1565C0),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Hero Header ──
          SliverToBoxAdapter(
            child: _buildHeroHeader(context, typedEvents),
          ),

          // ── Bölüm başlığı ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context).allEvents,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${events.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Boş durum ──
          if (events.isEmpty && state is EventLoaded)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 60, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).noEventsFound,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.read<EventCubit>().clearFilters(),
                      child: Text(AppLocalizations.of(context).clearFilters,
                          style: const TextStyle(color: AppColors.primaryColor)),
                    ),
                  ],
                ),
              ),
            ),

          // ── Etkinlik listesi ──
          if (events.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < events.length) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EventCard(event: events[index]),
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: AppLoadingIndicator(size: 28)),
                    );
                  },
                  childCount: events.length + (hasMore ? 1 : 0),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  // ---------- HERO HEADER ----------

  Widget _buildHeroHeader(BuildContext context, List<Event> typedEvents) {
    final upcoming =
        typedEvents.where((e) => e.date.isAfter(DateTime.now())).length;
    final onMap = typedEvents.where((e) => e.geoPoint != null).length;

    const Color headerStart = Color(0xFF1565C0);
    const Color headerEnd = Color(0xFF42A5F5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [headerStart, headerEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık satırı: sol=Etkinlikler, sağ=Filtre
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Sol: başlık + alt yazı
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).events,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              AppLocalizations.of(context).eventsSubtitle,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Sağ: filtre butonu
                      GestureDetector(
                        onTap: _showFilterModal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.tune_rounded,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                AppLocalizations.of(context).filter,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // İstatistik rozetleri
                  Row(
                    children: [
                      _buildStatBadge(
                          icon: Icons.event_rounded,
                          label: AppLocalizations.of(context)
                              .statUpcoming(upcoming)),
                      const SizedBox(width: 10),
                      _buildStatBadge(
                          icon: Icons.location_on_rounded,
                          label: AppLocalizations.of(context).statOnMap(onMap)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildMiniMap(typedEvents),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      extendBodyBehindAppBar: true,
      body: BlocBuilder<EventCubit, EventState>(
        builder: (context, state) => _buildBody(context, state),
      ),
      floatingActionButton: BlocBuilder<EventCubit, EventState>(
        builder: (context, state) {
          if (state is EventLoaded && state.isNgo) {
            return FloatingActionButton(
              onPressed: _showAddEventModal,
              heroTag: 'add_event_fab',
              backgroundColor: AppColors.primaryColor,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Mini harita pin kuyruğu
class _MiniPinTailPainter extends CustomPainter {
  final Color color;
  const _MiniPinTailPainter({required this.color});

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
  bool shouldRepaint(covariant _MiniPinTailPainter oldDelegate) =>
      color != oldDelegate.color;
}
