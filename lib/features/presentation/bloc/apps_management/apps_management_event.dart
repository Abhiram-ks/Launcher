part of 'apps_management_bloc.dart';

@immutable
sealed class AppsManagementEvent {}

class LoadAppsEvent extends AppsManagementEvent {}

class OpenAppEvent extends AppsManagementEvent {
  final String packageName;

  OpenAppEvent(this.packageName);
}