import 'package:equatable/equatable.dart';
import 'package:gonullunet_app/models/event_model.dart';

abstract class ActiveChatsState extends Equatable {
  const ActiveChatsState();

  @override
  List<Object?> get props => [];
}

class ActiveChatsInitial extends ActiveChatsState {}

class ActiveChatsLoading extends ActiveChatsState {}

class ActiveChatsLoaded extends ActiveChatsState {
  final List<Event> activeChats;

  const ActiveChatsLoaded(this.activeChats);

  @override
  List<Object?> get props => [activeChats];
}

class ActiveChatsError extends ActiveChatsState {
  final String message;

  const ActiveChatsError(this.message);

  @override
  List<Object?> get props => [message];
}
