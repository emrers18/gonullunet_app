import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/event_model.dart';
import '../repo/event_repository.dart';
import 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  final EventRepository _repository;
  StreamSubscription? _eventSubscription;
  List<Event> _allEvents = [];

  bool _isNgo = false;

  EventCubit(this._repository) : super(EventInitial());

  Future<void> loadEvents() async {
    try {
      emit(EventLoading());

      _isNgo = await _repository.isUserNgo();
      _eventSubscription?.cancel();

      _eventSubscription = _repository.getEventsStream().listen(
        (events) {
          _allEvents = events;
          emit(EventLoaded(events: _allEvents, isNgo: _isNgo));
        },
        onError: (error) {
          emit(EventError("Etkinlikler yüklenirken hata: $error"));
        },
      );
    } catch (e) {
      emit(EventError("Hata: $e"));
    }
  }

  void filterEvents({
    String? city,
    String? category,
    DateTimeRange? dateRange,
  }) {
    List<Event> filteredList = _allEvents;

    if (city != null && city.isNotEmpty) {
      filteredList = filteredList.where((event) {
        return event.location.toLowerCase().contains(city.toLowerCase());
      }).toList();
    }

    if (category != null && category.isNotEmpty && category != 'Tümü') {
      filteredList = filteredList.where((event) {
        return event.category == category;
      }).toList();
    }

    if (dateRange != null) {
      filteredList = filteredList.where((event) {
        return event.date
                .isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            event.date.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }

    emit(EventLoaded(events: filteredList, isNgo: _isNgo));
  }

  void clearFilters() {
    emit(EventLoaded(events: _allEvents, isNgo: _isNgo));
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    return super.close();
  }
}
