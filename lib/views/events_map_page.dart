import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gonullunet_app/models/event_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
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
      result = result.where((e) => e.category == _selectedCategory).toList();
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

  List<Marker> _buildMarkers() {
    return _filteredEvents.asMap().entries.map((entry) {
      final index = entry.key;
      final e = entry.value;
      final isSelected = index == _currentIndex;

      return Marker(
        point: LatLng(e.geoPoint!.latitude, e.geoPoint!.longitude),
        width: isSelected ? 48 : 36,
        height: isSelected ? 48 : 36,
        child: GestureDetector(
          onTap: () => _onMarkerTapped(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color:
                  isSelected ? AppColors.kPrimaryColor : Colors.blue.shade400,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: (isSelected ? AppColors.kPrimaryColor : Colors.blue)
                      .withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.location_on,
              color: Colors.white,
              size: isSelected ? 28 : 20,
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.gonullunet.gonullunet_app',
              ),
              MarkerLayer(
                markers: _buildMarkers(),
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
                  top: MediaQuery.of(context).padding.top + 10,
                  bottom: 10,
                  left: 16,
                  right: 16),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
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
                            decoration: const InputDecoration(
                              hintText: "Etkinlik ara...",
                              hintStyle: TextStyle(color: AppColors.textSub),
                              prefixIcon:
                                  Icon(Icons.search, color: AppColors.textSub),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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

                  const SizedBox(height: 12),

                  // Kategori Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories
                          .map((cat) => GestureDetector(
                                onTap: () => _onCategorySelected(cat),
                                child: _buildCategoryChip(
                                    cat, _selectedCategory == cat),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. KATMAN: LİSTE GÖRÜNÜM BUTONU (Sağ Üst)
          Positioned(
            top: 140,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.format_list_bulleted,
                      color: AppColors.kPrimaryColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Liste",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText),
                  ),
                ],
              ),
            ),
          ),

          // 4. KATMAN: KONUM BUTONU (Sağ Alt)
          Positioned(
            bottom: 160,
            right: 16,
            child: _buildCircleButton(
              icon: Icons.my_location,
              onTap: () {
                // Konuma gitme: ileride eklenebilir
              },
              size: 50,
            ),
          ),

          // 5. KATMAN: ALT ETKİNLİK KARTLARI
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            height: 140,
            child: _filteredEvents.isEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10),
                        ],
                      ),
                      child: const Text("Bu kritere uygun etkinlik bulunamadı.",
                          style: TextStyle(
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
                      return _buildEventCard(event);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET YARDIMCILARI ---

  Widget _buildEventCard(Event event) {
    final formattedDate =
        DateFormat('dd MMM, HH:mm', 'tr_TR').format(event.date);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            width: 100,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: CachedNetworkImageProvider(event.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.group,
                              size: 12, color: AppColors.kPrimaryColor),
                          const SizedBox(width: 2),
                          Text(
                            "${event.participants.length}",
                            style: const TextStyle(
                              fontSize: 10,
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
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.location_on, event.location),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildParticipantsBadge(event.participants.length),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                        minimumSize: const Size(0, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text("İncele",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _buildParticipantsBadge(int count) {
    if (count == 0) {
      return Text(
        "İlk sen ol!",
        style: TextStyle(color: Colors.grey[500], fontSize: 11),
      );
    }
    return Row(
      children: [
        Icon(Icons.people, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          "$count katılımcı",
          style: TextStyle(
            fontSize: 11,
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
        Icon(icon, size: 14, color: AppColors.textSub),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textSub),
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
        child: Icon(icon, color: AppColors.primaryText, size: 22),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.kPrimaryColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          fontSize: 13,
        ),
      ),
    );
  }
}
