import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/services/functions_service.dart';
import 'package:gonullunet_app/utils/app_messages.dart';
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
      // Cloud Function'dan dönen anlamlı (okunabilir) mesaj varsa olduğu gibi
      // göster; yoksa kod ile çevrilecek genel mesajı kullan.
      emit(SignUpError(e.message ?? AppErrorCodes.signupFailed));
    } catch (e) {
      emit(const SignUpError(AppErrorCodes.unexpectedRetry));
    }
  }
}
