import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gonullunet_app/models/event_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';

import 'event_detail_page.dart';

class EventsMapPage extends StatefulWidget {
  final List<Event> events;

  const EventsMapPage({super.key, required this.events});

  @override
  State<EventsMapPage> createState() => _EventsMapPageState();
}

class _EventsMapPageState extends State<EventsMapPage> {
  GoogleMapController? _mapController;
  late Set<Marker> _markers;
  late List<Event> _validEvents;
  late PageController _pageController;

  int _currentIndex = 0;
  static const LatLng _defaultLocation = LatLng(41.0082, 28.9784);

  @override
  void initState() {
    super.initState();
    _validEvents = widget.events.where((e) => e.geoPoint != null).toList();
    _markers = _createMarkers();
    _pageController =
        PageController(viewportFraction: 0.9); // Kartlar yanda hafif görünsün
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Markerları oluştur
  Set<Marker> _createMarkers() {
    return _validEvents.asMap().entries.map((entry) {
      final index = entry.key;
      final e = entry.value;

      // Seçili olan marker daha belirgin olsun (Hue Orange), diğerleri daha soluk veya farklı renk
      final isSelected = index == _currentIndex;

      return Marker(
        markerId: MarkerId(e.id),
        position: LatLng(e.geoPoint!.latitude, e.geoPoint!.longitude),
        // Seçili ise ikon rengini veya boyutunu değiştirebiliriz (Burada standart renk değişimi yapıldı)
        icon: BitmapDescriptor.defaultMarkerWithHue(isSelected
            ? BitmapDescriptor.hueOrange
            : BitmapDescriptor.hueAzure),
        onTap: () {
          _onMarkerTapped(index);
        },
      );
    }).toSet();
  }

  // Haritada marker'a tıklanınca
  void _onMarkerTapped(int index) {
    setState(() {
      _currentIndex = index;
      _markers = _createMarkers(); // Marker renklerini güncelle
    });
    // Alt kartı ilgili etkinliğe kaydır
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Alt kart kaydırılınca
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _markers = _createMarkers();
    });
    _moveCameraToEvent(index);
  }

  void _moveCameraToEvent(int index) {
    if (_validEvents.isEmpty || _mapController == null) return;
    final event = _validEvents[index];

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(event.geoPoint!.latitude, event.geoPoint!.longitude),
          zoom: 15, // Etkinliğe yaklaş
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. KATMAN: HARİTA (Tam Ekran)
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _validEvents.isNotEmpty
                    ? LatLng(_validEvents.first.geoPoint!.latitude,
                        _validEvents.first.geoPoint!.longitude)
                    : _defaultLocation,
                zoom: 12,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false, // Kendi butonumuzu yapacağız
              zoomControlsEnabled:
                  false, // Zoom butonlarını gizle (temiz görünüm)
              mapToolbarEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
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
                  // Üst Satır: Geri, Arama, Filtre
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
                          child: const TextField(
                            decoration: InputDecoration(
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
                      _buildCircleButton(icon: Icons.tune, onTap: () {}),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Kategoriler (Yatay Scroll)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip("Tümü", true),
                        _buildCategoryChip("Çevre", false),
                        _buildCategoryChip("Eğitim", false),
                        _buildCategoryChip("Hayvanlar", false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. KATMAN: LİSTE GÖRÜNÜM BUTONU (Sağ Üst)
          Positioned(
            top: 140, // Header'ın altına
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
            bottom: 160, // Kartların üstünde
            right: 16,
            child: _buildCircleButton(
                icon: Icons.my_location,
                onTap: () {
                  // Konuma gitme fonksiyonu buraya
                },
                size: 50),
          ),

          // 5. KATMAN: ALT ETKİNLİK KARTLARI (PageView)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            height: 140, // Kart yüksekliği
            child: _validEvents.isEmpty
                ? const SizedBox.shrink()
                : PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _validEvents.length,
                    itemBuilder: (context, index) {
                      final event = _validEvents[index];
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
          // Sol Resim Alanı
          Container(
            width: 100,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(
                    event.imageUrl), // Placeholder veya event resmi
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Sağ İçerik Alanı
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Başlık ve Puan
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
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star,
                              size: 12, color: Colors.green.shade700),
                          const SizedBox(width: 2),
                          Text(
                            "4.8", // Dinamik veri varsa event.rating kullanılabilir
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Tarih ve Konum Bilgisi
                Column(
                  children: [
                    _buildInfoRow(Icons.calendar_month,
                        "12 Mayıs, 10:00"), // Dinamik tarih verisi
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.location_on, event.location),
                  ],
                ),

                // Katılımcılar ve Buton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Fake Avatar Stack
                    SizedBox(
                      width: 60,
                      height: 24,
                      child: Stack(
                        children: [
                          _buildAvatar(0, Colors.blue),
                          _buildAvatar(15, Colors.red),
                          _buildAvatar(30, Colors.orange),
                        ],
                      ),
                    ),

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

  Widget _buildAvatar(double left, Color color) {
    return Positioned(
      left: left,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(Icons.person, size: 14, color: color),
      ),
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
