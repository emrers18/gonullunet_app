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
import '../utils/responsive.dart';
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
        width: Responsive.scale(context, 36),
        height: Responsive.scale(context, 44),
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Responsive.scale(context, 30),
              height: Responsive.scale(context, 30),
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
              child: Icon(
                Icons.event_rounded,
                color: Colors.white,
                size: Responsive.scale(context, 14),
              ),
            ),
            CustomPaint(
              size: Size(
                  Responsive.scale(context, 10), Responsive.scale(context, 8)),
              painter:
                  const _MiniPinTailPainter(color: AppColors.kPrimaryColor),
            ),
          ],
        ),
      );
    }).toList();

    return GestureDetector(
      onTap: () => _openFullMap(eventsWithLocation),
      child: Container(
        margin: Responsive.padding(context, horizontal: 16),
        height: Responsive.scale(context, 240),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Responsive.scale(context, 24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Responsive.scale(context, 24)),
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
                height: Responsive.scale(context, 60),
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
                height: Responsive.scale(context, 70),
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
                top: Responsive.scale(context, 12),
                right: Responsive.scale(context, 12),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(Responsive.scale(context, 24)),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: Responsive.padding(context,
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(
                            Responsive.scale(context, 24)),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.open_in_full_rounded,
                            size: Responsive.scale(context, 14),
                            color: eventsWithLocation.isNotEmpty
                                ? AppColors.kPrimaryColor
                                : Colors.grey,
                          ),
                          SizedBox(width: Responsive.scale(context, 5)),
                          Text(
                            AppLocalizations.of(context).fullScreen,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: Responsive.sp(context, 11),
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
                bottom: Responsive.scale(context, 12),
                left: Responsive.scale(context, 12),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(Responsive.scale(context, 20)),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: Responsive.padding(context,
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimaryColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(
                            Responsive.scale(context, 20)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on,
                              size: Responsive.scale(context, 13),
                              color: Colors.white),
                          SizedBox(width: Responsive.scale(context, 5)),
                          Text(
                            '${eventsWithLocation.length} etkinlik haritada',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: Responsive.sp(context, 11),
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
          padding: Responsive.padding(context, all: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded,
                  size: Responsive.scale(context, 56), color: Colors.grey[300]),
              SizedBox(height: Responsive.scale(context, 16)),
              Text(
                AppMessages.resolve(context, state.message),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: Responsive.sp(context, 15)),
              ),
              SizedBox(height: Responsive.scale(context, 20)),
              ElevatedButton.icon(
                onPressed: () => context.read<EventCubit>().refresh(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Responsive.scale(context, 20)),
                  ),
                  padding:
                      Responsive.padding(context, horizontal: 24, vertical: 12),
                ),
                icon: Icon(Icons.refresh_rounded,
                    size: Responsive.scale(context, 18)),
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
              padding: Responsive.padding(context,
                  left: 20, right: 20, top: 20, bottom: 8),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context).allEvents,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: Responsive.sp(context, 17),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(width: Responsive.scale(context, 8)),
                  Container(
                    padding:
                        Responsive.padding(context, horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(Responsive.scale(context, 12)),
                    ),
                    child: Text(
                      '${events.length}',
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 12),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1565C0),
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
                padding: Responsive.padding(context, top: 60),
                child: Column(
                  children: [
                    Icon(Icons.event_busy,
                        size: Responsive.scale(context, 60),
                        color: Colors.grey[300]),
                    SizedBox(height: Responsive.scale(context, 16)),
                    Text(
                      AppLocalizations.of(context).noEventsFound,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: Responsive.sp(context, 15)),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.read<EventCubit>().clearFilters(),
                      child: Text(AppLocalizations.of(context).clearFilters,
                          style:
                              const TextStyle(color: AppColors.primaryColor)),
                    ),
                  ],
                ),
              ),
            ),

          // ── Etkinlik listesi ──
          if (events.isNotEmpty)
            SliverPadding(
              padding: Responsive.padding(context, horizontal: 16, vertical: 4),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < events.length) {
                      return Padding(
                        padding: Responsive.padding(context, bottom: 12),
                        child: EventCard(event: events[index]),
                      );
                    }
                    return Padding(
                      padding: Responsive.padding(context, vertical: 20),
                      child: Center(
                          child: AppLoadingIndicator(
                              size: Responsive.scale(context, 28))),
                    );
                  },
                  childCount: events.length + (hasMore ? 1 : 0),
                ),
              ),
            ),

          SliverToBoxAdapter(
              child: SizedBox(height: Responsive.scale(context, 80))),
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
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [headerStart, headerEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(Responsive.scale(context, 28)),
              bottomRight: Radius.circular(Responsive.scale(context, 28)),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: Responsive.padding(context,
                  left: 20, right: 20, top: 12, bottom: 24),
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
                                fontSize: Responsive.sp(context, 28),
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: Responsive.scale(context, 3)),
                            Text(
                              AppLocalizations.of(context).eventsSubtitle,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: Responsive.sp(context, 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Sağ: filtre butonu
                      GestureDetector(
                        onTap: _showFilterModal,
                        child: Container(
                          padding: Responsive.padding(context,
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                                Responsive.scale(context, 20)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.tune_rounded,
                                  color: Colors.white,
                                  size: Responsive.scale(context, 16)),
                              SizedBox(width: Responsive.scale(context, 6)),
                              Text(
                                AppLocalizations.of(context).filter,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: Responsive.sp(context, 13),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.scale(context, 16)),
                  // İstatistik rozetleri
                  Row(
                    children: [
                      _buildStatBadge(
                          icon: Icons.event_rounded,
                          label: AppLocalizations.of(context)
                              .statUpcoming(upcoming)),
                      SizedBox(width: Responsive.scale(context, 10)),
                      _buildStatBadge(
                          icon: Icons.location_on_rounded,
                          label: AppLocalizations.of(context).statOnMap(onMap)),
                    ],
                  ),
                  SizedBox(height: Responsive.scale(context, 20)),
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
      padding: Responsive.padding(context, horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(Responsive.scale(context, 20)),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: Responsive.scale(context, 14)),
          SizedBox(width: Responsive.scale(context, 6)),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: Responsive.sp(context, 12),
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
                borderRadius:
                    BorderRadius.circular(Responsive.scale(context, 32)),
              ),
              child: Icon(Icons.add,
                  color: Colors.white, size: Responsive.scale(context, 24)),
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
