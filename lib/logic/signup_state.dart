import 'package:equatable/equatable.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {}

class SignUpError extends SignUpState {
  final String message;

  const SignUpError(this.message);

  @override
  List<Object> get props => [message];
}
