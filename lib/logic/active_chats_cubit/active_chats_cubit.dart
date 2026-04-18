import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/models/event_model.dart';
import 'package:gonullunet_app/repo/event_chat_repository.dart';
import 'package:gonullunet_app/services/firebase_error_translator.dart';
import 'active_chats_state.dart';

class ActiveChatsCubit extends Cubit<ActiveChatsState> {
  final EventChatRepository _repository;
  StreamSubscription<List<Event>>? _subscription;

  ActiveChatsCubit({required EventChatRepository repository})
      : _repository = repository,
        super(ActiveChatsInitial()) {
    _loadActiveChats();
  }

  void _loadActiveChats() {
    emit(ActiveChatsLoading());
    _subscription = _repository.getActiveChatsStream().listen(
      (activeChats) {
        if (!isClosed) {
          emit(ActiveChatsLoaded(activeChats));
        }
      },
      onError: (error) {
        if (!isClosed) {
          final translatedError =
              FirebaseErrorTranslator.translate(error.toString());
          emit(ActiveChatsError(translatedError));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
