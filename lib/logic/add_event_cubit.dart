import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/logic/add_event_state.dart';
import 'package:gonullunet_app/repo/event_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddEventCubit extends Cubit<AddEventState> {
  final EventRepository _repository;

  AddEventCubit(this._repository) : super(AddEventInitial());

  Future<void> addEvent({
    required String title,
    required String description,
    required String location,
    required LatLng coordinates,
    required DateTime startDate,
    required DateTime endDate,
    required String category,
    required String type,
    File? imageFile,
    int? quota,
  }) async {
    try {
      emit(AddEventLoading());

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _repository.uploadEventImage(imageFile);
      }

      await _repository.addEvent(
        title: title,
        description: description,
        location: location,
        coordinates: coordinates,
        startDate: startDate,
        endDate: endDate,
        category: category,
        type: type,
        imageUrl: imageUrl,
      );

      emit(AddEventSuccess());
    } catch (e) {
      emit(AddEventError("Etkinlik oluşturulamadı: $e"));
    }
  }
}
