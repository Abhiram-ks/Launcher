import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:minilauncher/features/model/data/appvalues.dart';

class AppIconState {
  final Uint8List? icon;
  final bool isLoading;
  final String? error;

  AppIconState({
    this.icon,
    this.isLoading = true,
    this.error,
  });

  AppIconState copyWith({
    Uint8List? icon,
    bool? isLoading,
    String? error,
  }) {
    return AppIconState(
      icon: icon ?? this.icon,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AppIconCubit extends Cubit<AppIconState> {
  AppIconCubit({required String packageName}) : super(AppIconState()) {
    _loadAppIcon(packageName);
  }

  Future<void> _loadAppIcon(String packageName) async {
    // First, try to get from cached apps (most optimized)
    try {
      final cachedApp = AppValues.allApps.firstWhere(
        (app) => app.packageName == packageName,
      );
      emit(state.copyWith(
        icon: cachedApp.icon,
        isLoading: false,
      ));
    } catch (e) {
      // If not in cache, load the specific app info
      try {
        final appInfo = await InstalledApps.getAppInfo(packageName);
        emit(state.copyWith(
          icon: appInfo?.icon,
          isLoading: false,
        ));
      } catch (e) {
        emit(state.copyWith(
          icon: null,
          isLoading: false,
          error: 'Error loading app icon: $e',
        ));
      }
    }
  }
}

