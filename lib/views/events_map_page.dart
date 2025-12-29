import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gonullunet_app/models/event_model.dart';
import 'package:gonullunet_app/utils/app_colors.dart';

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
  int _currentIndex = 0;

  static const LatLng _defaultLocation = LatLng(
      41.0082, 28.9784); //eğer herhangi bir etkinlik yoksa Istanbul'u gösteriyo

  @override
  void initState() {
    super.initState();
    _validEvents = widget.events.where((e) => e.geoPoint != null).toList();
    _markers = _createMarkers();
  }

  Set<Marker> _createMarkers() {
    return _validEvents.map((e) {
      return Marker(
        markerId: MarkerId(e.id),
        position: LatLng(e.geoPoint!.latitude, e.geoPoint!.longitude),
        infoWindow: InfoWindow(
          title: e.title,
          snippet: e.location,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );
    }).toSet();
  }

  void _goToNextEvent() {
    if (_validEvents.isEmpty || _mapController == null) return;

    setState(() {
      _currentIndex = (_currentIndex + 1) % _validEvents.length;
    });

    final nextEvent = _validEvents[_currentIndex];
    final target =
        LatLng(nextEvent.geoPoint!.latitude, nextEvent.geoPoint!.longitude);

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 15),
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Sıradaki: ${nextEvent.title}"),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Etkinlik Haritası",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _validEvents.isNotEmpty
                  ? LatLng(_validEvents.first.geoPoint!.latitude,
                      _validEvents.first.geoPoint!.longitude)
                  : _defaultLocation,
              zoom: 12,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          if (_validEvents.length > 1)
            Positioned(
              bottom: 30,
              left: 20,
              child: FloatingActionButton.extended(
                heroTag: 'next_event_fab',
                onPressed: _goToNextEvent,
                backgroundColor: AppColors.primaryColor,
                icon: const Icon(Icons.near_me, color: Colors.white),
                label: const Text(
                  "Sıradaki Etkinlik",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
