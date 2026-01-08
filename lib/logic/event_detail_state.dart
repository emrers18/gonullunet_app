import 'package:equatable/equatable.dart';

abstract class EventDetailState extends Equatable {
  const EventDetailState();
  @override
  List<Object> get props => [];
}

class EventDetailLoading extends EventDetailState {}

class EventDetailInitial extends EventDetailState {}

class EventDetailUpdated extends EventDetailState {
  final bool isJoined;
  final int participantCount;
  final String organizerName;

  const EventDetailUpdated(
      {required this.isJoined,
      required this.participantCount,
      required this.organizerName});

  @override
  List<Object> get props => [isJoined, participantCount];
}

class EventDetailLoaded extends EventDetailState {
  final bool isJoined;
  final int participantCount;
  final String organizerName;

  const EventDetailLoaded({
    required this.isJoined,
    required this.participantCount,
    required this.organizerName,
  });

  EventDetailLoaded copyWith({
    bool? isJoined,
    int? participantCount,
    String? organizerName,
  }) {
    return EventDetailLoaded(
      isJoined: isJoined ?? this.isJoined,
      participantCount: participantCount ?? this.participantCount,
      organizerName: organizerName ?? this.organizerName,
    );
  }

  @override
  List<Object> get props => [isJoined, participantCount, organizerName];
}
