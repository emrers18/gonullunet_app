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

  const EditProfileLoaded({
    required this.stkName,
    required this.description,
    required this.location,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [stkName, description, location, imageUrl];
}

class EditProfileUpdating extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {}

class EditProfileError extends EditProfileState {
  final String message;
  const EditProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
