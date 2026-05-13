import 'package:equatable/equatable.dart';
import 'package:gonullunet_app/models/chat_message_model.dart';
import 'package:gonullunet_app/models/chat_session_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatSessionsLoading extends ChatState {}

class ChatSessionsLoaded extends ChatState {
  final List<ChatSession> sessions;
  const ChatSessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class ChatMessagesLoaded extends ChatState {
  final String sessionId;
  final List<ChatMessage> messages;
  final bool isAiTyping;
  final String? errorMessage; // Yeni eklenen alan

  const ChatMessagesLoaded({
    required this.sessionId,
    required this.messages,
    this.isAiTyping = false,
    this.errorMessage,
  });

  ChatMessagesLoaded copyWith({
    String? sessionId,
    List<ChatMessage>? messages,
    bool? isAiTyping,
    String? errorMessage,
    bool clearError = false, // Hata mesajını temizlemek için yardımcı bayrak
  }) {
    return ChatMessagesLoaded(
      sessionId: sessionId ?? this.sessionId,
      messages: messages ?? this.messages,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [sessionId, messages, isAiTyping, errorMessage];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
