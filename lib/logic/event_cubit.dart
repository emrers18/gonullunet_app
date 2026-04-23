import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/services/firebase_error_translator.dart';
import '../models/event_model.dart';
import '../repo/event_repository.dart';
import 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  final EventRepository _repository;
  final List<Event> _allEvents = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isFetching = false;
  bool _isNgo = false;

  // Filter state
  String? _filterCity;
  String? _filterCategory;
  DateTimeRange? _filterDateRange;

  static const int _pageSize = 10;

  EventCubit(this._repository) : super(EventInitial());

  Future<void> loadEvents() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      // If first fetch, show full loading
      if (_allEvents.isEmpty) {
        emit(const EventLoading(isFirstFetch: true));
        _isNgo = await _repository.isUserNgo();
      } else {
        // Subsequent fetches: show loading indicator at bottom
        emit(EventLoading(
          isFirstFetch: false,
          oldEvents: _getFilteredEvents(),
        ));
      }

      if (!_hasMore) {
        emit(EventLoaded(
          events: _getFilteredEvents(),
          isNgo: _isNgo,
          hasMore: false,
        ));
        _isFetching = false;
        return;
      }

      final result = await _repository.getEventsPaginated(
        limit: _pageSize,
        lastDocument: _lastDocument,
      );

      _allEvents.addAll(result.events);
      _lastDocument = result.lastDoc;
      _hasMore = result.events.length >= _pageSize;

      emit(EventLoaded(
        events: _getFilteredEvents(),
        isNgo: _isNgo,
        hasMore: _hasMore,
      ));
    } catch (e) {
      emit(EventError(FirebaseErrorTranslator.translate(e)));
    } finally {
      _isFetching = false;
    }
  }

  /// Pull-to-refresh: reset pagination and reload from scratch
  Future<void> refresh() async {
    _filterCity = null;
    _filterCategory = null;
    _filterDateRange = null;
    _allEvents.clear();
    _lastDocument = null;
    _hasMore = true;
    _isFetching = false;
    await loadEvents();
  }

  void filterEvents({
    String? city,
    String? category,
    DateTimeRange? dateRange,
  }) {
    _filterCity = city;
    _filterCategory = category;
    _filterDateRange = dateRange;

    emit(EventLoaded(
      events: _getFilteredEvents(),
      isNgo: _isNgo,
      hasMore: _hasMore,
    ));
  }

  void clearFilters() {
    _filterCity = null;
    _filterCategory = null;
    _filterDateRange = null;

    emit(EventLoaded(
      events: _allEvents,
      isNgo: _isNgo,
      hasMore: _hasMore,
    ));
  }

  List<Event> _getFilteredEvents() {
    List<Event> filteredList = _allEvents;

    if (_filterCity != null && _filterCity!.isNotEmpty) {
      filteredList = filteredList.where((event) {
        return event.location
            .toLowerCase()
            .contains(_filterCity!.toLowerCase());
      }).toList();
    }

    if (_filterCategory != null &&
        _filterCategory!.isNotEmpty &&
        _filterCategory != 'Tümü') {
      filteredList = filteredList.where((event) {
        return event.category == _filterCategory;
      }).toList();
    }

    if (_filterDateRange != null) {
      filteredList = filteredList.where((event) {
        return event.date.isAfter(
                _filterDateRange!.start.subtract(const Duration(days: 1))) &&
            event.date
                .isBefore(_filterDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return filteredList;
  }


}
