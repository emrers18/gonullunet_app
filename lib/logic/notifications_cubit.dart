import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/notification_repository.dart';
import 'notidication_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;
  StreamSubscription? _subscription;

  NotificationCubit(this._repository) : super(NotificationInitial());

  void loadNotifications() {
    emit(NotificationLoading());
    _subscription?.cancel();
    _subscription = _repository.getNotifications().listen(
      (notifications) {
        emit(NotificationLoaded(notifications));
      },
      onError: (error) {
        emit(NotificationError("Bildirimler alınamadı: $error"));
      },
    );
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
