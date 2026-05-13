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

    // AI yazarken yeni mesaj gönderilmesini engelle
    if (currentState.isAiTyping) return;

    var sessionId = currentState.sessionId;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: 'user',
      createdAt: Timestamp.now(),
    );

    emit(currentState.copyWith(
      messages: [...currentState.messages, userMessage],
      isAiTyping: true,
      clearError: true,
    ));

    try {
      final response = await repository.sendMessage(sessionId, content);

      final stateNow = state;
      if (stateNow is ChatMessagesLoaded) {
        emit(stateNow.copyWith(
          sessionId: response.sessionId,
          messages: [...stateNow.messages, response.message],
          isAiTyping: false,
          clearError: true,
        ));
      }
    } catch (e) {
      final stateNow = state;
      // Hata mesajındaki teknik 'Exception:' kısmını temizle
      final cleanMessage =
          e.toString().replaceFirst(RegExp(r'Exception:?\s*'), '');

      if (stateNow is ChatMessagesLoaded) {
        emit(stateNow.copyWith(
          isAiTyping: false,
          errorMessage: cleanMessage,
        ));
      } else {
        emit(ChatError(cleanMessage));
      }
    }
  }

  void clearError() {
    final currentState = state;
    if (currentState is ChatMessagesLoaded) {
      emit(currentState.copyWith(clearError: true));
    }
  }
}
