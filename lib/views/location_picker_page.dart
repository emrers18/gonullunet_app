import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  LatLng? _currentCameraPosition;

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LocationCubit, LocationState>(
        listener: (context, state) {
          if (state is LocationLoaded && state.shouldMoveCamera) {
            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: state.location, zoom: 15),
              ),
            );
            _currentCameraPosition = state.location;
          } else if (state is LocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Stack(
          children: [
            BlocBuilder<LocationCubit, LocationState>(
              buildWhen: (previous, current) {
                return previous
                        is LocationInitial && //optimize harita kullanımını sağlıyor, tekrar tekrar rebuild etmiyo
                    current is LocationLoading;
              },
              builder: (context, state) {
                LatLng initialTarget = const LatLng(41.0082, 28.9784);

                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialTarget,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onCameraMove: (position) {
                    _currentCameraPosition = position.target;
                  },
                  onCameraIdle: () {
                    if (_currentCameraPosition != null) {
                      context
                          .read<LocationCubit>()
                          .onCameraIdle(_currentCameraPosition!);
                    }
                  },
                );
              },
            ),
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
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40.0),
                child: Icon(
                  Icons.location_on,
                  size: 50,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
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
