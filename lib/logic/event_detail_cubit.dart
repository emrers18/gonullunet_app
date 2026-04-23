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
    final status = await _repository.getUserApplicationStatus(_event.id, _currentUserId);
    final isJoined = status == 'approved';

    final count = _event.participants.length;
    final organizerName =
        await _repository.getOrganizerName(_event.organizerId);

    emit(EventDetailLoaded(
      isJoined: isJoined,
      participantCount: count,
      organizerName: organizerName,
      applicationStatus: status,
    ));
  }

  Future<void> toggleJoin() async {
    if (_currentUserId.isEmpty) return;

    final currentState = state;
    if (currentState is EventDetailLoaded) {
      try {
        final currentStatus = currentState.applicationStatus;
        String? nextStatus;
        int nextCount = currentState.participantCount;

        if (currentStatus == 'approved') {
          // Ayrılma
          nextStatus = null;
          nextCount = nextCount - 1;
        } else if (currentStatus == 'pending') {
          // İptal
          nextStatus = null;
        } else {
          // Başvuru
          nextStatus = 'pending';
        }

        // Optimistik güncelleme
        emit(currentState.copyWith(
          isJoined: nextStatus == 'approved',
          applicationStatus: nextStatus,
          participantCount: nextCount,
        ));

        await _repository.toggleJoinEvent(_event.id, _currentUserId);
        
        // İşlem sonrası gerçek durumu tekrar çek (sayaç senkronizasyonu için önemli)
        await _loadPageData();
      } catch (e) {
        emit(currentState);
      }
    }
  }
}
