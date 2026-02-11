import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/user_repository.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;
  StreamSubscription? _userSubscription;

  UserCubit(this._repository) : super(UserInitial());

  void loadUser() {
    emit(UserLoading());
    _userSubscription?.cancel();
    _userSubscription = _repository.getUserStream().listen(
      (user) {
        if (user != null) {
          emit(UserLoaded(user));
        } else {
          emit(const UserError("Kullanıcı verisi bulunamadı"));
        }
      },
      onError: (error) {
        emit(UserError("Hata: $error"));
      },
    );
  }

  Future<void> toggleFollow(String ngoId) async {
    try {
      await _repository.toggleFollowNgo(ngoId);
    } catch (e) {
      emit(UserError("Takip işlemi başarısız: $e"));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
