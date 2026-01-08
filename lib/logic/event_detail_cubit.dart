import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/event_repository.dart';
import '../models/event_model.dart';
import 'event_detail_state.dart';

class EventDetailCubit extends Cubit<EventDetailState> {
  final EventRepository _repository;
  final Event _event;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  EventDetailCubit(this._repository, this._event)
      : super(EventDetailLoading()) {
    _loadPageData();
  }

  Future<void> _loadPageData() async {
    final isJoined = _event.participants.contains(_currentUserId);
    final count = _event.participants.length;

    final organizerName =
        await _repository.getOrganizerName(_event.organizerId);

    emit(EventDetailLoaded(
      isJoined: isJoined,
      participantCount: count,
      organizerName: organizerName,
    ));
  }

  Future<void> toggleJoin() async {
    if (_currentUserId.isEmpty) return;

    final currentState = state;
    if (currentState is EventDetailLoaded) {
      try {
        if (_event.type == 'Proje') {
          if (!currentState.isJoined) {
            emit(currentState.copyWith(isJoined: true));

            await _repository.applyToEvent(_event.id, _currentUserId);
          } else {
            return;
          }
        } else {
          final newStatus = !currentState.isJoined;
          final newCount = newStatus
              ? currentState.participantCount + 1
              : currentState.participantCount - 1;

          emit(currentState.copyWith(
            isJoined: newStatus,
            participantCount: newCount,
          ));

          await _repository.toggleJoinEvent(_event.id, _currentUserId);
        }
      } catch (e) {
        emit(currentState);
      }
    }
  }
}
