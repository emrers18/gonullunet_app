import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/models/event_chat_message_model.dart';
import 'package:gonullunet_app/repo/event_chat_repository.dart';
import 'package:gonullunet_app/services/firebase_error_translator.dart';
import 'event_chat_state.dart';

class EventChatCubit extends Cubit<EventChatState> {
  final EventChatRepository _repository;
  StreamSubscription<List<EventChatMessage>>? _messagesSubscription;
  final String eventId;
  final String currentUserFullName;
  final String? currentUserAvatarUrl;

  EventChatCubit({
    required EventChatRepository repository,
    required this.eventId,
    required this.currentUserFullName,
    this.currentUserAvatarUrl,
  })  : _repository = repository,
        super(EventChatInitial()) {
    _initChat();
  }

  void _initChat() {
    emit(EventChatLoading());

    _messagesSubscription =
        _repository.getEventMessagesStream(eventId).listen((messages) {
      if (!isClosed) {
        emit(EventChatLoaded(messages));
      }
    }, onError: (error) {
      if (!isClosed) {
        final translatedError =
            FirebaseErrorTranslator.translate(error.toString());
        emit(EventChatError(translatedError));
      }
    });
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    List<EventChatMessage> currentMessages = [];
    if (state is EventChatLoaded) {
      currentMessages = (state as EventChatLoaded).messages;
    }

    emit(EventChatMessageSending(currentMessages));

    try {
      await _repository.sendMessage(
        eventId: eventId,
        content: content.trim(),
        senderName: currentUserFullName,
        senderAvatarUrl: currentUserAvatarUrl,
      );
      // State transition handled by StreamSubscription automatically
    } catch (e) {
      final translatedError =
          FirebaseErrorTranslator.translate(e.toString());
      emit(EventChatError(translatedError));
      // Optionally fallback to Loaded state if needed, stream usually triggers update anyway
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
