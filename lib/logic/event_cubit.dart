import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/services/cache_service.dart';
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
      if (_allEvents.isEmpty) {
        // Ilk yüklemede once cache'i goster
        final cached = _loadFromCache();
        if (cached.isNotEmpty) {
          emit(EventLoaded(
            events: cached,
            isNgo: _isNgo,
            hasMore: true,
            fromCache: true,
          ));
        } else {
          emit(const EventLoading(isFirstFetch: true));
        }

        _isNgo = await _repository.isUserNgo();
      } else {
        // Sonraki sayfalar: altta spinner
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

      // Ilk sayfayi cache'e kaydet
      if (_lastDocument == result.lastDoc && _allEvents.isNotEmpty) {
        _saveToCache(_allEvents.take(_pageSize).toList());
      }
    } catch (e) {
      emit(EventError(FirebaseErrorTranslator.translate(e)));
    } finally {
      _isFetching = false;
    }
  }

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
        _filterCategory != 'Tumu') {
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

  // -------------------------------------------------------------------------
  // Cache yardimci metodlari
  // -------------------------------------------------------------------------

  List<Event> _loadFromCache() {
    try {
      final raw = CacheService.readList(CacheKeys.events);
      return raw.map((j) => Event.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  void _saveToCache(List<Event> events) {
    try {
      CacheService.writeList(
          CacheKeys.events, events.map((e) => e.toJson()).toList());
    } catch (_) {}
  }
}
