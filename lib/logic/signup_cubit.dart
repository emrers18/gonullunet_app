import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/services/functions_service.dart';
import 'signup_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final FunctionsService _functionsService = FunctionsService();

  SignUpCubit() : super(SignUpInitial());

  Future<void> signUp({
    required String email,
    required String password,
    required String userType,
    String? name,
    String? surname,
    String? stkName,
  }) async {
    emit(SignUpLoading());

    try {
      await _functionsService.registerUser(
        email: email,
        password: password,
        userType: userType,
        name: name,
        surname: surname,
        stkName: stkName,
      );

      emit(SignUpSuccess(email: email));
    } on FirebaseFunctionsException catch (e) {
      // Cloud Function'dan dönen anlamlı hata mesajlarını direkt kullan
      emit(SignUpError(e.message ?? 'Kayıt sırasında bir hata oluştu.'));
    } catch (e) {
      emit(const SignUpError(
          'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.'));
    }
  }
}
