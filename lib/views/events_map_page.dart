import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gonullunet_app/l10n/app_localizations.dart';
import 'package:gonullunet_app/models/event_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:gonullunet_app/utils/category_localizer.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../utils/responsive.dart';
import 'event_detail_page.dart';

class EventsMapPage extends StatefulWidget {
  final List<Event> events;

  const EventsMapPage({super.key, required this.events});

  @override
  State<EventsMapPage> createState() => _EventsMapPageState();
}

class _EventsMapPageState extends State<EventsMapPage> {
  final MapController _mapController = MapController();
  late List<Event> _allEvents;
  late List<Event> _filteredEvents;
  late PageController _pageController;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tümü';

  int _currentIndex = 0;
  static const LatLng _defaultLocation = LatLng(41.0082, 28.9784);

  @override
  void initState() {
    super.initState();
    _allEvents = widget.events.where((e) => e.geoPoint != null).toList();
    _filteredEvents = List.from(_allEvents);
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ---------- FİLTRELEME ----------

  void _applyFilters() {
    List<Event> result = _allEvents;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((e) {
        return e.title.toLowerCase().contains(q) ||
            e.location.toLowerCase().contains(q);
      }).toList();
    }

    if (_selectedCategory != 'Tümü') {
      result = result.where((e) => e.type == _selectedCategory).toList();
    }

    setState(() {
      _filteredEvents = result;
      _currentIndex = 0;
    });

    if (_filteredEvents.isNotEmpty && _pageController.hasClients) {
      _pageController.jumpToPage(0);
    }

    if (_filteredEvents.isNotEmpty) {
      _moveCameraToEvent(0);
    }
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _onCategorySelected(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  // ---------- HARİTA ----------

  void _onMarkerTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _moveCameraToEvent(index);
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _moveCameraToEvent(index);
  }

  void _moveCameraToEvent(int index) {
    if (_filteredEvents.isEmpty) return;
    final event = _filteredEvents[index];
    _mapController.move(
      LatLng(event.geoPoint!.latitude, event.geoPoint!.longitude),
      15.0,
    );
  }

  List<Marker> _buildMarkers(BuildContext context) {
    return _filteredEvents.asMap().entries.map((entry) {
      final index = entry.key;
      final e = entry.value;
      final isSelected = index == _currentIndex;

      return Marker(
        point: LatLng(e.geoPoint!.latitude, e.geoPoint!.longitude),
        width: Responsive.scale(context, isSelected ? 52 : 40),
        height: Responsive.scale(context, isSelected ? 62 : 48),
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => _onMarkerTapped(index),
          child: AnimatedScale(
            scale: isSelected ? 1.0 : 0.8,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: Responsive.scale(context, isSelected ? 42 : 34),
                  height: Responsive.scale(context, isSelected ? 42 : 34),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.kPrimaryColor
                        : AppColors.kSecondaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isSelected
                                ? AppColors.kPrimaryColor
                                : AppColors.kSecondaryColor)
                            .withOpacity(0.4),
                        blurRadius: isSelected ? 12 : 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    e.type == 'Proje'
                        ? Icons.work_rounded
                        : Icons.event_rounded,
                    color: Colors.white,
                    size: Responsive.scale(context, isSelected ? 20 : 16),
                  ),
                ),
                // Pin tail
                CustomPaint(
                  size: Size(Responsive.scale(context, 12),
                      Responsive.scale(context, isSelected ? 10 : 8)),
                  painter: _PinTailPainter(
                    color: isSelected
                        ? AppColors.kPrimaryColor
                        : AppColors.kSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = ['Tümü', ...AppConstants.eventCategories];
    final initialCenter = _filteredEvents.isNotEmpty
        ? LatLng(_filteredEvents.first.geoPoint!.latitude,
            _filteredEvents.first.geoPoint!.longitude)
        : _defaultLocation;

    return Scaffold(
      body: Stack(
        children: [
          // 1. KATMAN: HARİTA (Tam Ekran)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.gonullunet.gonullunet_app',
              ),
              MarkerLayer(
                markers: _buildMarkers(context),
              ),
            ],
          ),

          // 2. KATMAN: ÜST ARAMA VE FİLTRE ALANI
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + Responsive.scale(context, 10),
                  bottom: Responsive.scale(context, 10),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst Satır: Geri, Arama, Filtre Temizle
                  Row(
                    children: [
                      _buildCircleButton(
                          icon: Icons.arrow_back,
                          onTap: () => Navigator.pop(context)),
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
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: l10n.searchEvent,
                              hintStyle: const TextStyle(color: AppColors.textSub),
                              prefixIcon: const Icon(Icons.search,
                                  color: AppColors.textSub),
                              border: InputBorder.none,
                              contentPadding:
                                  Responsive.padding(context, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.scale(context, 12)),
                      _buildCircleButton(
                        icon: Icons.tune,
                        onTap: () {
                          _searchController.clear();
                          _searchQuery = '';
                          _selectedCategory = 'Tümü';
                          _applyFilters();
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: Responsive.scale(context, 12)),

                  // Kategori Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories
                          .map((cat) => GestureDetector(
                                onTap: () => _onCategorySelected(cat),
                                child: _buildCategoryChip(
                                    CategoryLocalizer.category(l10n, cat),
                                    _selectedCategory == cat),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. KATMAN: KÜÇÜLT BUTONU (Sağ Üst)
          Positioned(
            top: Responsive.scale(context, 140),
            right: Responsive.scale(context, 16),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding:
                    Responsive.padding(context, horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Responsive.scale(context, 30)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.close_fullscreen_rounded,
                        color: AppColors.kPrimaryColor, size: Responsive.scale(context, 20)),
                    SizedBox(width: Responsive.scale(context, 8)),
                    Text(
                      l10n.shrink,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. KATMAN: KONUM BUTONU (Sağ Alt)
          Positioned(
            bottom: Responsive.scale(context, 160),
            right: Responsive.scale(context, 16),
            child: _buildCircleButton(
              icon: Icons.my_location,
              onTap: () {
                // Konuma gitme: ileride eklenebilir
              },
              size: Responsive.scale(context, 50),
            ),
          ),

          // 5. KATMAN: ALT ETKİNLİK KARTLARI
          Positioned(
            bottom: Responsive.scale(context, 20),
            left: 0,
            right: 0,
            height: Responsive.scale(context, 140),
            child: _filteredEvents.isEmpty
                ? Center(
                    child: Container(
                      padding: Responsive.padding(context,
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(Responsive.scale(context, 20)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10),
                        ],
                      ),
                      child: Text(l10n.noEventsForCriteria,
                          style: const TextStyle(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w500)),
                    ),
                  )
                : PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = _filteredEvents[index];
                      return _buildEventCard(context, event);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET YARDIMCILARI ---

  Widget _buildEventCard(BuildContext context, Event event) {
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final formattedDate =
        DateFormat('dd MMM, HH:mm', localeName).format(event.date);

    return Container(
      margin: Responsive.padding(context, horizontal: 8),
      padding: Responsive.padding(context, all: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.scale(context, 20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: Responsive.scale(context, 100),
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Responsive.scale(context, 16)),
              image: DecorationImage(
                image: CachedNetworkImageProvider(event.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: Responsive.scale(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: Responsive.sp(context, 16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    Container(
                      padding: Responsive.padding(context,
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Responsive.scale(context, 8)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.group,
                              size: Responsive.scale(context, 12), color: AppColors.kPrimaryColor),
                          SizedBox(width: Responsive.scale(context, 2)),
                          Text(
                            "${event.participants.length}",
                            style: TextStyle(
                              fontSize: Responsive.sp(context, 10),
                              fontWeight: FontWeight.bold,
                              color: AppColors.kPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    _buildInfoRow(Icons.calendar_month, formattedDate),
                    SizedBox(height: Responsive.scale(context, 4)),
                    _buildInfoRow(Icons.location_on, event.location),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildParticipantsBadge(context, event.participants.length),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailPage(event: event),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kPrimaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: Responsive.padding(context,
                            horizontal: 16, vertical: 0),
                        minimumSize: Size(0, Responsive.scale(context, 32)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.scale(context, 20)),
                        ),
                      ),
                      child: Text(l10n.examine,
                          style: TextStyle(
                              fontSize: Responsive.sp(context, 12), fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildParticipantsBadge(BuildContext context, int count) {
    final l10n = AppLocalizations.of(context);
    if (count == 0) {
      return Text(
        l10n.beFirstToJoin,
        style: TextStyle(color: Colors.grey[500], fontSize: Responsive.sp(context, 11)),
      );
    }
    return Row(
      children: [
        Icon(Icons.people, size: Responsive.scale(context, 16), color: Colors.grey[500]),
        SizedBox(width: Responsive.scale(context, 4)),
        Text(
          l10n.participantCount(count),
          style: TextStyle(
            fontSize: Responsive.sp(context, 11),
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: Responsive.scale(context, 14), color: AppColors.textSub),
        SizedBox(width: Responsive.scale(context, 4)),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: Responsive.sp(context, 12), color: AppColors.textSub),
          ),
        ),
      ],
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

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: Responsive.padding(context, right: 8),
      padding: Responsive.padding(context, horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.kPrimaryColor : Colors.white,
        borderRadius: BorderRadius.circular(Responsive.scale(context, 20)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.primaryText,
          fontWeight: FontWeight.bold,
          fontSize: Responsive.sp(context, 13),
        ),
      ),
    );
  }
}

/// Pin'in alt ucundaki üçgen kuyruk çizimi
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
