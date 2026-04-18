import 'package:equatable/equatable.dart';
import 'package:gonullunet_app/models/event_chat_message_model.dart';

abstract class EventChatState extends Equatable {
  const EventChatState();

  @override
  List<Object?> get props => [];
}

class EventChatInitial extends EventChatState {}

class EventChatLoading extends EventChatState {}

class EventChatLoaded extends EventChatState {
  final List<EventChatMessage> messages;

  const EventChatLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class EventChatError extends EventChatState {
  final String message;

  const EventChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class EventChatMessageSending extends EventChatState {
  final List<EventChatMessage> currentMessages;

  const EventChatMessageSending(this.currentMessages);

  @override
  List<Object?> get props => [currentMessages];
}
