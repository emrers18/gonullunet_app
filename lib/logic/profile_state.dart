import 'package:equatable/equatable.dart';

abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

class EditProfileInitial extends EditProfileState {}

class EditProfileLoading extends EditProfileState {}

class EditProfileLoaded extends EditProfileState {
  final String stkName;
  final String description;
  final String location;
  final String? imageUrl;
  final String vision;
  final String mission;
  final String phone;
  final String email;
  final String facebookUrl;
  final String instagramUrl;
  final String twitterUrl;
  final String linkedinUrl;

  const EditProfileLoaded({
    required this.stkName,
    required this.description,
    required this.location,
    this.imageUrl,
    required this.vision,
    required this.mission,
    required this.phone,
    required this.email,
    this.facebookUrl = '',
    this.instagramUrl = '',
    this.twitterUrl = '',
    this.linkedinUrl = '',
  });

  @override
  List<Object?> get props => [stkName, description, location, imageUrl];
}

class EditVolunteerProfileLoaded extends EditProfileState {
  final String name;
  final String surname;
  final String email;
  final String? imageUrl;
  final String bio;
  final List<String> interests;
  final List<String> skills;
  final dynamic birthDate; // Timestamp?
  final String education;
  final String city;
  final String phone;

  const EditVolunteerProfileLoaded({
    required this.name,
    required this.surname,
    required this.email,
    this.imageUrl,
    required this.bio,
    required this.interests,
    required this.skills,
    this.birthDate,
    required this.education,
    required this.city,
    required this.phone,
  });

  @override
  List<Object?> get props => [
        name,
        surname,
        email,
        imageUrl,
        bio,
        interests,
        skills,
        birthDate,
        education,
        city,
        phone
      ];
}

class EditProfileUpdating extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {}

class EditProfileError extends EditProfileState {
  final String message;
  const EditProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
