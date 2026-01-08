import 'package:equatable/equatable.dart';
import 'package:gonullunet_app/models/application_model.dart';

abstract class ManageApplicationsState extends Equatable {
  const ManageApplicationsState();

  @override
  List<Object> get props => [];
}

class ManageApplicationsInitial extends ManageApplicationsState {}

class ManageApplicationsLoading extends ManageApplicationsState {}

class ManageApplicationsLoaded extends ManageApplicationsState {
  final List<ApplicationModel> applications;

  const ManageApplicationsLoaded(this.applications);

  @override
  List<Object> get props => [applications];
}

class ManageApplicationsError extends ManageApplicationsState {
  final String message;

  const ManageApplicationsError(this.message);

  @override
  List<Object> get props => [message];
}
