import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/models/chat_message_model.dart';
import 'package:gonullunet_app/repo/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repository;

  ChatCubit(this.repository) : super(ChatInitial());

  // ── Sessions ──────────────────────────────────────────────

  Future<void> loadSessions() async {
    emit(ChatSessionsLoading());
    try {
      final sessions = await repository.getSessions();
      emit(ChatSessionsLoaded(sessions));
    } catch (e) {
      emit(ChatError('Sohbet geçmişi yüklenemedi: $e'));
    }
  }

  Future<void> startNewSession() async {
    // Don't create Firestore doc yet — only when first message is sent
    final tempId = '_new_${DateTime.now().millisecondsSinceEpoch}';
    emit(ChatMessagesLoaded(
      sessionId: tempId,
      messages: const [],
    ));
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await repository.deleteSession(sessionId);
      await loadSessions();
    } catch (e) {
      emit(ChatError('Sohbet silinemedi: $e'));
    }
  }

  // ── Messages ──────────────────────────────────────────────

  Future<void> loadMessages(String sessionId) async {
    try {
      final messages = await repository.getMessages(sessionId);
      emit(ChatMessagesLoaded(
        sessionId: sessionId,
        messages: messages,
      ));
    } catch (e) {
      emit(ChatError('Mesajlar yüklenemedi: $e'));
    }
  }

  Future<void> sendMessage(String content) async {
    final currentState = state;
    if (currentState is! ChatMessagesLoaded) return;

    var sessionId = currentState.sessionId;

    // Add user message locally for immediate UI feedback
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: 'user',
      createdAt: Timestamp.now(),
    );

    emit(currentState.copyWith(
      messages: [...currentState.messages, userMessage],
      isAiTyping: true,
    ));

    try {
      // Create the Firestore session on first message
      if (sessionId.startsWith('_new_')) {
        final session = await repository.createSession();
        sessionId = session.id;
      }

      await repository.sendMessage(sessionId, content);

      // Reload messages from Firestore to get the correct message IDs
      final updatedMessages = await repository.getMessages(sessionId);
      emit(ChatMessagesLoaded(
        sessionId: sessionId,
        messages: updatedMessages,
        isAiTyping: false,
      ));
    } catch (e) {
      // Keep user message, remove typing indicator, show error state briefly
      final stateNow = state;
      if (stateNow is ChatMessagesLoaded) {
        emit(stateNow.copyWith(isAiTyping: false));
      }
      emit(ChatError('Mesaj gönderilemedi: $e'));
    }
  }
}
