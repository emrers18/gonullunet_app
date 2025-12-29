import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/services/auth.dart';
import 'signup_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final Auth _auth = Auth();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      UserCredential userCredential = await _auth.createUser(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      Map<String, dynamic> userData = {
        'uid': uid,
        'email': email,
        'userType': userType,
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': '',
      };

      if (userType == 'ngo') {
        userData['stkName'] = stkName;
        userData['description'] = '';
        userData['location'] = '';
      } else {
        userData['name'] = name;
        userData['surname'] = surname;
      }

      await _firestore.collection('users').doc(uid).set(userData);

      emit(SignUpSuccess());
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Kayıt başarısız.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Bu e-posta adresi zaten kullanılıyor.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Şifre çok zayıf.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Geçersiz e-posta adresi.';
      }
      emit(SignUpError(errorMessage));
    } catch (e) {
      emit(SignUpError('Bir hata oluştu: $e'));
    }
  }
}
