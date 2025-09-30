part of 'apps_management_bloc.dart';

@immutable
sealed class AppsManagementState {}

class AppsManagementInitial extends AppsManagementState {}

class AppsManagementLoading extends AppsManagementState {}

class AppsManagementLoaded extends AppsManagementState {
  final List<ApplicationWithIcon> apps;

  AppsManagementLoaded(this.apps);
}

class AppsManagementError extends AppsManagementState {
  final String message;

  AppsManagementError(this.message);
}