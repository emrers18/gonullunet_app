import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/models/ngo_model.dart';
import '../repo/ngo_repository.dart';
import 'ngo_state.dart';

class NgoCubit extends Cubit<NgoState> {
  final NgoRepository _repository;
  StreamSubscription? _ngoSubscription;

  List<Ngo> _allNgos = [];
  String _searchQuery = '';
  String? _cityFilter;

  NgoCubit(this._repository) : super(NgoInitial());

  Future<void> loadNgos() async {
    try {
      emit(NgoLoading());
      _ngoSubscription?.cancel();

      _ngoSubscription = _repository.getNgosStream().listen(
        (ngos) {
          _allNgos = ngos;
          _applyFilters();
        },
        onError: (error) {
          emit(NgoError("Kurumlar yüklenirken hata oluştu: $error"));
        },
      );
    } catch (e) {
      emit(NgoError("Beklenmedik bir hata: $e"));
    }
  }

  void searchNgos(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _applyFilters() {
    List<Ngo> filteredList = _allNgos;

    // Arama Metni Filtresi
    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList.where((ngo) {
        return ngo.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Şehir Filtresi
    if (_cityFilter != null && _cityFilter!.isNotEmpty) {
      filteredList = filteredList.where((ngo) {
        // location string'i içinde şehir adı geçiyor mu?
        return ngo.location.toLowerCase().contains(_cityFilter!.toLowerCase());
      }).toList();
    }

    emit(NgoLoaded(filteredList));
  }

  @override
  Future<void> close() {
    _ngoSubscription?.cancel();
    return super.close();
  }
}
