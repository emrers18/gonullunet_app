import 'package:equatable/equatable.dart';
import 'package:gonullunet_app/models/event_model.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {
  final bool isFirstFetch;
  final List<Event> oldEvents;

  const EventLoading({
    this.isFirstFetch = true,
    this.oldEvents = const [],
  });

  @override
  List<Object?> get props => [isFirstFetch, oldEvents];
}

class EventLoaded extends EventState {
  final List<Event> events;
  final bool isNgo;
  final bool hasMore;
  final bool fromCache; // true ise veri cache'den geldi

  const EventLoaded({
    required this.events,
    required this.isNgo,
    this.hasMore = true,
    this.fromCache = false,
  });

  @override
  List<Object?> get props => [events, isNgo, hasMore, fromCache];
}

class EventError extends EventState {
  final String message;

  const EventError(this.message);

  @override
  List<Object?> get props => [message];
}
