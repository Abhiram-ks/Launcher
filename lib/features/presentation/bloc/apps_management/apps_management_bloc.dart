import 'package:bloc/bloc.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
part 'apps_management_event.dart';
part 'apps_management_state.dart';

class AppsManagementBloc
    extends Bloc<AppsManagementEvent, AppsManagementState> {
  AppsManagementBloc() : super(AppsManagementInitial()) {
    on<LoadAppsEvent>(_onLoadApps);
    on<OpenAppEvent>(_onOpenApp);
  }

  Future<void> _onLoadApps(
      LoadAppsEvent event, Emitter<AppsManagementState> emit) async {
    emit(AppsManagementLoading());
    try {
      List<Application> installedApps =
          await DeviceApps.getInstalledApplications(
        includeSystemApps: false,
        onlyAppsWithLaunchIntent: true,
        includeAppIcons: true,
      );

      final apps = installedApps.cast<ApplicationWithIcon>();
      emit(AppsManagementLoaded(apps));
    } catch (e) {
      emit(AppsManagementError(e.toString()));
    }
  }

  Future<void> _onOpenApp(
      OpenAppEvent event, Emitter<AppsManagementState> emit) async {
    DeviceApps.openApp(event.packageName);
  }
}