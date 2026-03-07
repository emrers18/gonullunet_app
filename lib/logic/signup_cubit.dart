import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/services/auth.dart';
import 'package:gonullunet_app/services/firebase_error_translator.dart';
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

      // Kayıt başarılı — doğrulama e-postası gönder
      await userCredential.user?.sendEmailVerification();

      emit(SignUpSuccess(email: email));
    } catch (e) {
      emit(SignUpError(FirebaseErrorTranslator.translate(e)));
    }
  }
}
