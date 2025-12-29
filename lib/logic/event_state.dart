import 'package:equatable/equatable.dart';
import 'package:gonullunet_app/models/event_model.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventLoaded extends EventState {
  final List<Event> events;
  final bool isNgo;

  const EventLoaded({required this.events, required this.isNgo});

  @override
  List<Object> get props => [events, isNgo];
}

class EventError extends EventState {
  final String message;

  const EventError(this.message);

  @override
  List<Object> get props => [message];
}
