import 'package:equatable/equatable.dart';
import 'package:gonullunet_app/models/ngo_model.dart';

abstract class NgoState extends Equatable {
  const NgoState();

  @override
  List<Object> get props => [];
}

class NgoInitial extends NgoState {}

class NgoLoading extends NgoState {}

class NgoLoaded extends NgoState {
  final List<Ngo> ngos;

  const NgoLoaded(this.ngos);

  @override
  List<Object> get props => [ngos];
}

class NgoError extends NgoState {
  final String message;

  const NgoError(this.message);

  @override
  List<Object> get props => [message];
}
