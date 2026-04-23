import 'package:equatable/equatable.dart';

abstract class EventDetailState extends Equatable {
  const EventDetailState();
  @override
  List<Object?> get props => [];
}

class EventDetailLoading extends EventDetailState {}

class EventDetailInitial extends EventDetailState {}

class EventDetailUpdated extends EventDetailState {
  final bool isJoined;
  final int participantCount;
  final String organizerName;
  final String? applicationStatus;

  const EventDetailUpdated({
    required this.isJoined,
    required this.participantCount,
    required this.organizerName,
    this.applicationStatus,
  });

  @override
  List<Object?> get props =>
      [isJoined, participantCount, organizerName, applicationStatus];
}

class EventDetailLoaded extends EventDetailState {
  final bool isJoined;
  final int participantCount;
  final String organizerName;
  final String? applicationStatus;

  const EventDetailLoaded({
    required this.isJoined,
    required this.participantCount,
    required this.organizerName,
    this.applicationStatus,
  });

  EventDetailLoaded copyWith({
    bool? isJoined,
    int? participantCount,
    String? organizerName,
    String? applicationStatus,
  }) {
    return EventDetailLoaded(
      isJoined: isJoined ?? this.isJoined,
      participantCount: participantCount ?? this.participantCount,
      organizerName: organizerName ?? this.organizerName,
      applicationStatus: applicationStatus ?? this.applicationStatus,
    );
  }

  @override
  List<Object?> get props =>
      [isJoined, participantCount, organizerName, applicationStatus];
}

/// Başvuru gibi işlemler sırasında oluşan geçici hata.
/// UI bunu SnackBar ile gösterip bir önceki state'e dönebilir.
class EventDetailError extends EventDetailState {
  final String message;
  const EventDetailError(this.message);

  @override
  List<Object> get props => [message];
}
