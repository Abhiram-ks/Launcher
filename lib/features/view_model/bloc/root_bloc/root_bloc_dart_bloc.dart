import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:minilauncher/core/service/launcher_service.dart';
import 'package:minilauncher/features/model/data/appvalues.dart';
import 'package:minilauncher/features/model/data/priority_apps_localdb.dart';
import 'package:minilauncher/features/model/data/wallpapper_prefs_localdb.dart';

import '../../../model/models/app_model.dart';

part 'root_bloc_dart_event.dart';
part 'root_bloc_dart_state.dart';

class RootBloc extends Bloc<RootEvent, RootState> {
  String _currentWallpaper = 'assets/wallpapers/10.jpg';
  RootBloc() : super(RootInitial()) {
    on<LoadAppsEvent> (loadAppsEvent);
    on<LaunchAppEvent> (launchAppEvent);
    on<LoadAllPrioritizedAppsEvent> (loadAllPrioritizedAppsEvent);
    on<RootInitialEvent> (rootInitialEvent);
    on<SavePriorityAppsEvent> (savePriorityAppsEvent);
    on<TogglePriorityAppEvent> (togglePriorityAppEvent);
    on<ResetToShowPrioritizedEvent> ((event, emit) => emit(ShowPrioritizedAllAppsLoadedResetState()));
    on<LoadWallpaperEvent>(_loadWallpaperEvent);
    on<SetWallpaperEvent>(_setWallpaperEvent);
    on<SelectWallpaperEvent>(_selectWallpaperEvent);
    on<EditPriorityAppsEvent> (editPriorityAppsEvent);

    add(LoadWallpaperEvent());
  }

  String get currentWallpaper => _currentWallpaper;

  Future<void> _loadWallpaperEvent(LoadWallpaperEvent event, Emitter<RootState> emit) async {
    _currentWallpaper = await WallpaperPrefs().getWallpaper();
    emit(WallpaperLoadedState(currentWallpaper: _currentWallpaper));
    AppValues.isAppDefault = await LauncherService.isDefaultLauncher();
  }

  Future<void> _setWallpaperEvent(SetWallpaperEvent event, Emitter<RootState> emit) async {
    emit(WallpaperLoadingState());
    _currentWallpaper = event.wallpaperPath;
    await WallpaperPrefs().setWallpaper(event.wallpaperPath);
    emit(WallpaperLoadedState(currentWallpaper: _currentWallpaper));
  }

  Future<void> _selectWallpaperEvent(SelectWallpaperEvent event, Emitter<RootState> emit) async {
    List<String> availableWallpapers = List.generate(
        12,(index) => 'assets/wallpapers/$index.jpg'
    );

    final currentWallpaper = await WallpaperPrefs().getWallpaper();

    emit(SelectWallpaperScreenState(
      availableWallpapers: availableWallpapers,
      selectedWallpaper: event.wallpaperPath,
      currentWallpaper: currentWallpaper,
    ));
  }


  Future<void> loadAppsEvent(LoadAppsEvent event, Emitter<RootState> emit) async {
    emit(PreparingAllAppsLoadingState());
    List<Application> allApps = AppValues.allApps;
    if (allApps.isEmpty) {
      allApps = await DeviceApps.getInstalledApplications(includeSystemApps:true, onlyAppsWithLaunchIntent: true, includeAppIcons: true);
    }
    emit(PreparedAllAppsLoadedState());
    emit(InitialAllAppsLoadedState(allApps: allApps.map((app) => AppsModel(app: app)).toList()));
    AppValues.allApps = await DeviceApps.getInstalledApplications(includeSystemApps:true, onlyAppsWithLaunchIntent: true, includeAppIcons: true);
  }



  FutureOr<void> launchAppEvent(LaunchAppEvent event, Emitter<RootState> emit) {
    DeviceApps.openApp(event.packageName);
  }

  Future<void> loadAllPrioritizedAppsEvent(LoadAllPrioritizedAppsEvent event, Emitter<RootState> emit) async {
    List<String> prioritizedPackageNames = await PriorityAppsPrefs().getPriorityApps();
    List<Application> allApps = AppValues.allApps;
    if (allApps.isEmpty) {
      allApps = await DeviceApps.getInstalledApplications(includeSystemApps:true, onlyAppsWithLaunchIntent: true, includeAppIcons: true);
    }
    List<AppsModel> prioritizedApps = allApps.where((app) => prioritizedPackageNames.contains(app.packageName)).map((app) => AppsModel(app: app)).toList();
    emit(LoadPrioritizedAppsState(prioritizedApps: prioritizedApps));
    AppValues.allApps = await DeviceApps.getInstalledApplications(includeSystemApps:true, onlyAppsWithLaunchIntent: true, includeAppIcons: true);
  }

  Future<void> rootInitialEvent(RootInitialEvent event, Emitter<RootState> emit) async {
    List<String> prioritizedPackageNames = await PriorityAppsPrefs().getPriorityApps();
    if (prioritizedPackageNames.isEmpty) {
      List<Application> allApps = AppValues.allApps;
      if (allApps.isEmpty) {
        allApps = await DeviceApps.getInstalledApplications(includeSystemApps:true, onlyAppsWithLaunchIntent: true, includeAppIcons: true);
      }
      List<AppsModel> allAppsModels = allApps.map((app) => AppsModel(app: app)).toList();
      emit(SelectPriorityAppState(allApps: allAppsModels, selectedPackages: {}));
      AppValues.allApps = await DeviceApps.getInstalledApplications(includeSystemApps:true, onlyAppsWithLaunchIntent: true, includeAppIcons: true);
    } else {
      add(LoadAllPrioritizedAppsEvent());
    }
  }

  FutureOr<void> savePriorityAppsEvent(SavePriorityAppsEvent event, Emitter<RootState> emit) {
    PriorityAppsPrefs().setPriorityApps(event.packageNames);
    add(LoadAllPrioritizedAppsEvent());
  }

  FutureOr<void> togglePriorityAppEvent(TogglePriorityAppEvent event, Emitter<RootState> emit) {
    if (state is SelectPriorityAppState) {
      final currentState = state as SelectPriorityAppState;
      final selectedPackages = Set<String>.from(currentState.selectedPackages);
      if (selectedPackages.contains(event.packageName)) {
        selectedPackages.remove(event.packageName);
      } else {
        selectedPackages.add(event.packageName);
      }
      emit(currentState.copyWith(selectedPackages: selectedPackages));
    }
  }

  Future<void> editPriorityAppsEvent(EditPriorityAppsEvent event, Emitter<RootState> emit) async {
    List<String> prioritizedPackageNames = await PriorityAppsPrefs().getPriorityApps();
    List<Application> allApps = AppValues.allApps;
    if (allApps.isEmpty) {
      allApps = await DeviceApps.getInstalledApplications(includeSystemApps:true, onlyAppsWithLaunchIntent: true, includeAppIcons: true);
    }
    List<AppsModel> allAppsModels = allApps.map((app) => AppsModel(app: app)).toList();
    emit(SelectPriorityAppState(allApps: allAppsModels, selectedPackages: prioritizedPackageNames.toSet()));
    AppValues.allApps = await DeviceApps.getInstalledApplications(includeSystemApps:true, onlyAppsWithLaunchIntent: true, includeAppIcons: true);
  }
}