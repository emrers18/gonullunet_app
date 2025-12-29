import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/event_repository.dart';
import 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  final EventRepository _repository;
  StreamSubscription? _eventSubscription;

  EventCubit(this._repository) : super(EventInitial());

  Future<void> loadEvents() async {
    try {
      emit(EventLoading());

      final isNgo = await _repository.isUserNgo();

      _eventSubscription?.cancel();
      _eventSubscription = _repository.getEventsStream().listen(
        (events) {
          emit(EventLoaded(events: events, isNgo: isNgo));
        },
        onError: (error) {
          emit(EventError("Etkinlikler yüklenirken hata oluştu: $error"));
        },
      );
    } catch (e) {
      emit(EventError("Beklenmedik bir hata: $e"));
    }
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    return super.close();
  }
}
