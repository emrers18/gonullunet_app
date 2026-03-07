import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final LatLng location;
  final String address;
  final bool shouldMoveCamera;

  const LocationLoaded({
    required this.location,
    required this.address,
    this.shouldMoveCamera = false,
  });

  @override
  List<Object?> get props => [location, address, shouldMoveCamera];
}

class LocationError extends LocationState {
  final String message;
  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
}
