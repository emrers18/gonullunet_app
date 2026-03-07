import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gonullunet_app/services/firebase_error_translator.dart';
import '../repo/user_repository.dart';
import 'profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UserRepository _repository;

  EditProfileCubit(this._repository) : super(EditProfileInitial());

  Future<void> loadProfileData() async {
    try {
      emit(EditProfileLoading());
      final data = await _repository.getCurrentUserData();

      if (data != null) {
        emit(EditProfileLoaded(
          stkName: data['stkName'] ?? '',
          description: data['description'] ?? '',
          location: data['location'] ?? '',
          phone: data['phone'] ?? '',
          vision: data['vision'] ?? '',
          mission: data['mission'] ?? '',
          imageUrl: data['imageUrl'],
          email: data['email'],
        ));
      } else {
        emit(const EditProfileError("Kullanıcı verisi bulunamadı."));
      }
    } catch (e) {
      emit(EditProfileError(FirebaseErrorTranslator.translate(e)));
    }
  }

  Future<void> updateProfile({
    required String stkName,
    required String description,
    required String location,
    required String phone,
    required String vision,
    required String mission,
    File? imageFile,
  }) async {
    try {
      emit(EditProfileUpdating());

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _repository.uploadProfileImage(imageFile);
      }

      await _repository.updateNgoProfile(
        stkName: stkName,
        description: description,
        location: location,
        imageUrl: imageUrl,
        phone: phone,
        vision: vision,
        mission: mission,
      );

      emit(EditProfileSuccess());
    } catch (e) {
      emit(EditProfileError(FirebaseErrorTranslator.translate(e)));
    }
  }

  Future<void> loadVolunteerProfileData() async {
    try {
      emit(EditProfileLoading());
      final data = await _repository.getCurrentUserData();

      if (data != null) {
        emit(EditVolunteerProfileLoaded(
          name: data['name'] ?? '',
          surname: data['surname'] ?? '',
          email: data['email'] ?? '',
          imageUrl: data['imageUrl'],
          bio: data['bio'] ?? '',
          interests: List<String>.from(data['interests'] ?? []),
          skills: List<String>.from(data['skills'] ?? []),
          birthDate: data['birthDate'],
          education: data['education'] ?? '',
          city: data['city'] ?? '',
          phone: data['phone'] ?? '',
        ));
      } else {
        emit(const EditProfileError("Kullanıcı verisi bulunamadı."));
      }
    } catch (e) {
      emit(EditProfileError(FirebaseErrorTranslator.translate(e)));
    }
  }

  Future<void> updateVolunteerProfile({
    required String bio,
    required List<String> interests,
    required List<String> skills,
    DateTime? birthDate,
    required String education,
    required String city,
    required String phone,
    File? imageFile,
  }) async {
    try {
      emit(EditProfileUpdating());

      await _repository.updateVolunteerProfile(
        bio: bio,
        interests: interests,
        skills: skills,
        birthDate: birthDate,
        education: education,
        city: city,
        phone: phone,
        imageFile: imageFile,
      );

      emit(EditProfileSuccess());
    } catch (e) {
      emit(EditProfileError(FirebaseErrorTranslator.translate(e)));
    }
  }
}
