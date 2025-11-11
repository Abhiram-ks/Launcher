import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:flutter/material.dart';
import 'package:minilauncher/core/service/launcher_service.dart';
import 'package:minilauncher/core/service/app_events_service.dart';
import 'package:minilauncher/features/model/data/appvalues.dart';
import 'package:minilauncher/features/model/data/priority_apps_localdb.dart';
import 'package:minilauncher/features/model/data/wallpapper_prefs_localdb.dart';

import '../../../model/models/app_model.dart';

part 'root_bloc_dart_event.dart';
part 'root_bloc_dart_state.dart';

class RootBloc extends Bloc<RootEvent, RootState> {
  String _currentWallpaper = 'assets/wallpapers/10.jpg';
  StreamSubscription? _appEventsSubscription;
  
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
    on<AppInstalledEvent> (_onAppInstalled);
    on<AppUninstalledEvent> (_onAppUninstalled);
    on<AppUpdatedEvent> (_onAppUpdated);
    on<RefreshAppsEvent> (_onRefreshApps);

    add(LoadWallpaperEvent());
    _listenToAppEvents();
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
    
    // Use stream for progressive loading
    await emit.forEach<List<AppsModel>>(
      _loadAppsStream(),
      onData: (apps) {
        if (apps.isEmpty) {
          return PreparingAllAppsLoadingState();
        }
        return InitialAllAppsLoadedState(allApps: apps);
      },
    );
  }

  Stream<List<AppsModel>> _loadAppsStream() async* {
    // First, check if apps are already cached
    if (AppValues.allApps.isNotEmpty) {
      yield AppValues.allApps.map((app) => AppsModel(app: app)).toList();
      return;
    }

    // Emit loading state
    yield [];

    // Load apps in the background
    final allApps = await InstalledApps.getInstalledApps(
      excludeSystemApps: false, 
      withIcon: true
    );
    
    AppValues.allApps = allApps;
    
    // Emit progressively in chunks for faster UI updates
    const chunkSize = 20;
    List<AppsModel> loadedApps = [];
    
    for (int i = 0; i < allApps.length; i++) {
      loadedApps.add(AppsModel(app: allApps[i]));
      
      // Emit every chunk for progressive loading
      if ((i + 1) % chunkSize == 0 || i == allApps.length - 1) {
        yield List.from(loadedApps);
      }
    }
  }



  FutureOr<void> launchAppEvent(LaunchAppEvent event, Emitter<RootState> emit) {
    InstalledApps.startApp(event.packageName);
  }

  Future<void> loadAllPrioritizedAppsEvent(LoadAllPrioritizedAppsEvent event, Emitter<RootState> emit) async {
    await emit.forEach<List<AppsModel>>(
      _loadPrioritizedAppsStream(),
      onData: (prioritizedApps) => LoadPrioritizedAppsState(prioritizedApps: prioritizedApps),
    );
  }

  Stream<List<AppsModel>> _loadPrioritizedAppsStream() async* {
    final prioritizedPackageNames = await PriorityAppsPrefs().getPriorityApps();
    
    // Get all apps
    List<AppInfo> allApps = AppValues.allApps;
    if (allApps.isEmpty) {
      allApps = await InstalledApps.getInstalledApps(
        excludeSystemApps: false, 
        withIcon: true
      );
      AppValues.allApps = allApps;
    }

    // Filter and collect all prioritized apps
    List<AppsModel> prioritizedApps = allApps
        .where((app) => prioritizedPackageNames.contains(app.packageName))
        .map((app) => AppsModel(app: app))
        .toList();
    
    // Emit once with complete list - prioritized apps are usually few, no need for chunking
    yield prioritizedApps;
  }

  Future<void> rootInitialEvent(RootInitialEvent event, Emitter<RootState> emit) async {
    final prioritizedPackageNames = await PriorityAppsPrefs().getPriorityApps();
    
    if (prioritizedPackageNames.isEmpty) {
      // Load all apps at once for selection screen to avoid multiple Navigator.pop() calls
      List<AppInfo> allApps = AppValues.allApps;
      if (allApps.isEmpty) {
        allApps = await InstalledApps.getInstalledApps(
          excludeSystemApps: false, 
          withIcon: true
        );
        AppValues.allApps = allApps;
      }
      List<AppsModel> allAppsModels = allApps.map((app) => AppsModel(app: app)).toList();
      emit(SelectPriorityAppState(allApps: allAppsModels, selectedPackages: {}));
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
    final prioritizedPackageNames = await PriorityAppsPrefs().getPriorityApps();
    
    // Load all apps at once for selection screen to avoid multiple Navigator.pop() calls
    List<AppInfo> allApps = AppValues.allApps;
    if (allApps.isEmpty) {
      allApps = await InstalledApps.getInstalledApps(
        excludeSystemApps: false, 
        withIcon: true
      );
      AppValues.allApps = allApps;
    }
    List<AppsModel> allAppsModels = allApps.map((app) => AppsModel(app: app)).toList();
    emit(SelectPriorityAppState(allApps: allAppsModels, selectedPackages: prioritizedPackageNames.toSet()));
  }

  /// Listen to real-time app install/uninstall events
  void _listenToAppEvents() {
    _appEventsSubscription = AppEventsService.appEventsStream.listen((event) {
      final eventType = event['event'] as String?;
      final packageName = event['packageName'] as String?;

      if (packageName != null) {
        switch (eventType) {
          case 'app_installed':
            add(AppInstalledEvent(packageName: packageName));
            break;
          case 'app_uninstalled':
            add(AppUninstalledEvent(packageName: packageName));
            break;
          case 'app_updated':
            add(AppUpdatedEvent(packageName: packageName));
            break;
          case 'app_changed':
            add(RefreshAppsEvent());
            break;
        }
      }
    });
  }

  /// Handle app installed event
  Future<void> _onAppInstalled(AppInstalledEvent event, Emitter<RootState> emit) async {
    debugPrint('App Installed: ${event.packageName}');
    // Refresh the entire app list to include the new app
    add(RefreshAppsEvent());
  }

  /// Handle app uninstalled event
  Future<void> _onAppUninstalled(AppUninstalledEvent event, Emitter<RootState> emit) async {
    debugPrint(' App Uninstalled: ${event.packageName}');
    
    // Remove from cached list
    AppValues.allApps.removeWhere((app) => app.packageName == event.packageName);
    
    // Remove from priority apps if it was there
    final priorityApps = await PriorityAppsPrefs().getPriorityApps();
    if (priorityApps.contains(event.packageName)) {
      priorityApps.remove(event.packageName);
      await PriorityAppsPrefs().setPriorityApps(priorityApps);
    }
    
    // Refresh the UI
    add(RefreshAppsEvent());
  }

  /// Handle app updated event
  Future<void> _onAppUpdated(AppUpdatedEvent event, Emitter<RootState> emit) async {
    debugPrint('App Updated: ${event.packageName}');
    // Refresh to get updated app info
    add(RefreshAppsEvent());
  }

  /// Refresh the app list after changes
  Future<void> _onRefreshApps(RefreshAppsEvent event, Emitter<RootState> emit) async {
    debugPrint('Refreshing app list...');
    
    // Reload apps from system
    final allApps = await InstalledApps.getInstalledApps(
      excludeSystemApps: false, 
      withIcon: true
    );
    AppValues.allApps = allApps;

    // Check current state and emit appropriate update
    if (state is LoadPrioritizedAppsState) {
      // Reload prioritized apps
      add(LoadAllPrioritizedAppsEvent());
    } else if (state is InitialAllAppsLoadedState) {
      // Reload all apps in the main view
      emit(InitialAllAppsLoadedState(
        allApps: allApps.map((app) => AppsModel(app: app)).toList()
      ));
    } else if (state is SelectPriorityAppState) {
      // Reload for selection screen
      final currentState = state as SelectPriorityAppState;
      emit(SelectPriorityAppState(
        allApps: allApps.map((app) => AppsModel(app: app)).toList(),
        selectedPackages: currentState.selectedPackages,
      ));
    }
  }

  @override
  Future<void> close() {
    _appEventsSubscription?.cancel();
    return super.close();
  }
}