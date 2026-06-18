import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationInitial());

  static const LatLng _defaultLocation = LatLng(41.0082, 28.9784); // İstanbul

  Future<void> getCurrentLocation() async {
    emit(LocationLoading());
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _getAddressFromLatLng(_defaultLocation, moveCamera: true);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          await _getAddressFromLatLng(_defaultLocation, moveCamera: true);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await _getAddressFromLatLng(_defaultLocation, moveCamera: true);
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      await _getAddressFromLatLng(currentLatLng, moveCamera: true);
    } catch (e) {
      emit(const LocationError(AppErrorCodes.locationFailed));
      await _getAddressFromLatLng(_defaultLocation, moveCamera: true);
    }
  }

  Future<void> onCameraIdle(LatLng position) async {
    await _getAddressFromLatLng(position, moveCamera: false);
  }

  Future<void> searchLocation(String query) async {
    if (query.trim().isEmpty) return;
    emit(LocationLoading());

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location loc = locations.first;
        LatLng newPos = LatLng(loc.latitude, loc.longitude);
        await _getAddressFromLatLng(newPos, moveCamera: true);
      } else {
        emit(const LocationError(AppErrorCodes.locationNotFound));
      }
    } catch (e) {
      emit(const LocationError(AppErrorCodes.searchFailed));
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position,
      {bool moveCamera = false}) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = AppErrorCodes.unknownLocation;
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        address =
            "${place.thoroughfare ?? ''} ${place.subAdministrativeArea ?? place.locality}, ${place.administrativeArea}";
        address = address.trim();
        if (address.startsWith(',')) address = address.substring(1).trim();
      }

      emit(LocationLoaded(
        location: position,
        address: address,
        shouldMoveCamera: moveCamera,
      ));
    } catch (e) {
      emit(LocationLoaded(
        location: position,
        address: AppErrorCodes.addressDetail,
        shouldMoveCamera: moveCamera,
      ));
    }
  }
}
