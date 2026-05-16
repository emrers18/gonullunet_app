import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/logic/add_event_state.dart';
import 'package:gonullunet_app/repo/event_repository.dart';
import 'package:gonullunet_app/services/firebase_error_translator.dart';
import 'package:latlong2/latlong.dart';

class AddEventCubit extends Cubit<AddEventState> {
  final EventRepository _repository;

  AddEventCubit(this._repository) : super(AddEventInitial());

  Future<void> addEvent({
    required String title,
    required String description,
    required String location,
    required LatLng coordinates,
    required DateTime startDate,
    required DateTime endDate,
    required String category,
    required String type,
    File? imageFile,
    int? quota,
  }) async {
    try {
      emit(AddEventLoading());

      // 1. Gorsel yuklemeyi dene — basarisiz olursa resimsiz devam et
      String? imageUrl;
      if (imageFile != null) {
        // uploadEventImage artik null donebiliyor (Storage erisimi yoksa)
        imageUrl = await _repository.uploadEventImage(imageFile);
        if (imageUrl == null && kDebugMode) {
          debugPrint('[AddEventCubit] Gorsel yuklenemedi, etkinlik resimsiz olusturuluyor.');
        }
      }

      // 2. Etkinligi Cloud Function uzerinden olustur
      await _repository.addEvent(
        title: title,
        description: description,
        location: location,
        coordinates: coordinates,
        startDate: startDate,
        endDate: endDate,
        category: category,
        type: type,
        imageUrl: imageUrl,
        quota: quota,
      );

      emit(AddEventSuccess());
    } on FirebaseFunctionsException catch (e) {
      if (kDebugMode) {
        debugPrint('[AddEventCubit] CF Hatasi: [${e.code}] ${e.message}');
      }
      // CF hata kodlarini anlamli mesajlara cevir
      final String message;
      switch (e.code) {
        case 'permission-denied':
          message = 'Etkinlik olusturmak icin STK hesabiniz olmalidir.';
          break;
        case 'unauthenticated':
          message = 'Bu islemi yapmak icin giris yapmaniz gerekiyor.';
          break;
        case 'invalid-argument':
          message = e.message ?? 'Lutfen tum alanlari doldurun.';
          break;
        case 'not-found':
          message = 'Kullanici profili bulunamadi.';
          break;
        default:
          message = e.message ?? 'Etkinlik olusturulamadi. Lutfen tekrar deneyin.';
      }
      emit(AddEventError(message));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AddEventCubit] Hata: $e');
      }
      emit(AddEventError(FirebaseErrorTranslator.translate(e)));
    }
  }
}
