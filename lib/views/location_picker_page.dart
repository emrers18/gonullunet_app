import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:gonullunet_app/utils/app_colors.dart';

import '../logic/location_cubit.dart';
import '../logic/location_state.dart';

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
      body: BlocListener<LocationCubit, LocationState>(
        listener: (context, state) {
          if (state is LocationLoaded && state.shouldMoveCamera) {
            _mapController.move(state.location, 15.0);
          } else if (state is LocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Stack(
          children: [
            // --- HARİTA ---
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
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.gonullunet.gonullunet_app',
                ),
              ],
            ),

            // --- Ortadaki Sabit Pin ---
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: AnimatedScale(
                  scale: _isCameraMoving ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: const Icon(
                    Icons.location_on,
                    size: 50,
                    color: AppColors.primaryColor,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                ),
              ),
            ),

            // --- Üst Arama Çubuğu ---
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
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
                  decoration: InputDecoration(
                    hintText: "Konum ara (Örn: Taksim Meydanı)",
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search,
                          color: AppColors.primaryColor),
                      onPressed: () {
                        context
                            .read<LocationCubit>()
                            .searchLocation(_searchController.text);
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // --- Konumuma Git Butonu ---
            Positioned(
              bottom: 180,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'my_location_btn_cubit',
                mini: true,
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: Colors.black87),
                onPressed: () {
                  context.read<LocationCubit>().getCurrentLocation();
                },
              ),
            ),

            // --- Alt Onay Paneli ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2))
                  ],
                ),
                child: BlocBuilder<LocationCubit, LocationState>(
                  builder: (context, state) {
                    String displayAddress = "Konum seçiliyor...";
                    LatLng? confirmCoordinates;

                    if (state is LocationLoaded) {
                      displayAddress = state.address;
                      confirmCoordinates = state.location;
                    } else if (state is LocationLoading) {
                      displayAddress = "Yükleniyor...";
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Seçilen Konum:",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (state is LocationLoading)
                          const Center(
                              child: LinearProgressIndicator(
                                  color: AppColors.primaryColor))
                        else
                          ElevatedButton(
                            onPressed: confirmCoordinates == null
                                ? null
                                : () {
                                    Navigator.pop(context, {
                                      'geoPoint': confirmCoordinates,
                                      'address': displayAddress,
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Bu Konumu Onayla",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
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
}
