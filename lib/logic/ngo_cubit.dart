import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/ngo_repository.dart';
import 'ngo_state.dart';

class NgoCubit extends Cubit<NgoState> {
  final NgoRepository _repository;
  StreamSubscription? _ngoSubscription;

  NgoCubit(this._repository) : super(NgoInitial());

  Future<void> loadNgos() async {
    try {
      emit(NgoLoading());
      _ngoSubscription?.cancel();
      _ngoSubscription = _repository.getNgosStream().listen(
        (ngos) {
          emit(NgoLoaded(ngos));
        },
        onError: (error) {
          emit(NgoError("Kurumlar yüklenirken hata oluştu: $error"));
        },
      );
    } catch (e) {
      emit(NgoError("Beklenmedik bir hata: $e"));
    }
  }

  @override
  Future<void> close() {
    _ngoSubscription?.cancel();
    return super.close();
  }
}
