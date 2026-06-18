import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
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
          emit(const UserError(AppErrorCodes.userDataNotFound));
        }
      },
      onError: (error) {
        emit(const UserError(AppErrorCodes.unexpected));
      },
    );
  }

  Future<void> toggleFollow(String ngoId) async {
    try {
      await _repository.toggleFollowNgo(ngoId);
    } catch (e) {
      emit(const UserError(AppErrorCodes.followFailed));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
