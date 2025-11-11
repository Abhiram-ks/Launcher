part of 'root_bloc_dart_bloc.dart';

@immutable
abstract class RootEvent {}

abstract class WallpaperEvent extends RootEvent {}

class LoadWallpaperEvent extends WallpaperEvent {}

class SetWallpaperEvent extends WallpaperEvent {
  final String wallpaperPath;
  SetWallpaperEvent({required this.wallpaperPath});
}

class SelectWallpaperEvent extends WallpaperEvent {
  final String wallpaperPath;
  SelectWallpaperEvent({required this.wallpaperPath});
}

class RootInitialEvent extends RootEvent {}

class LoadAppsEvent extends RootEvent {}

class LaunchAppEvent extends RootEvent {
  final String packageName;
  LaunchAppEvent({required this.packageName});
}

class EditPriorityAppsEvent extends RootEvent {}

class LoadAllPrioritizedAppsEvent extends RootEvent {}

class SavePriorityAppsEvent extends RootEvent {
  final List<String> packageNames;
  SavePriorityAppsEvent({required this.packageNames});
}

class TogglePriorityAppEvent extends RootEvent {
  final String packageName;
  TogglePriorityAppEvent(this.packageName);
}

class ResetToShowPrioritizedEvent extends RootEvent {}

// App lifecycle events
class AppInstalledEvent extends RootEvent {
  final String packageName;
  AppInstalledEvent({required this.packageName});
}

class AppUninstalledEvent extends RootEvent {
  final String packageName;
  AppUninstalledEvent({required this.packageName});
}

class AppUpdatedEvent extends RootEvent {
  final String packageName;
  AppUpdatedEvent({required this.packageName});
}

class RefreshAppsEvent extends RootEvent {}