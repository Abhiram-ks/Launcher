import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/core/service/app_usage_service.dart';
import 'package:minilauncher/features/model/data/app_usage_prefs.dart';
import 'usage_state.dart';

class UsageCubit extends Cubit<UsageState> {
  UsageCubit() : super(UsageState.initial());

  /// Load initial data
  Future<void> init() async {
    emit(state.copyWith(isLoading: true));
    
    try {
      // Check permission
      final hasPermission = await AppUsageService.hasUsagePermission();
      
      // Get monitoring status
      final isMonitoring = await AppUsagePrefs().isMonitoringEnabled();
      
      // Get time limit
      final timeLimit = await AppUsagePrefs().getTimeLimit();
      
      emit(state.copyWith(
        hasPermission: hasPermission,
        isMonitoring: isMonitoring,
        timeLimitMinutes: timeLimit,
        isLoading: false,
        clearError: true,
      ));
      
      // Load today's usage if permission granted
      if (hasPermission) {
        await loadTodayUsage();
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Start monitoring
  Future<void> startMonitoring(int timeLimitMinutes) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      // Check permission first
      final hasPermission = await AppUsageService.hasUsagePermission();
      
      if (!hasPermission) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Usage permission not granted',
        ));
        return;
      }
      
      // Save time limit
      await AppUsagePrefs().setTimeLimit(timeLimitMinutes);
      
      // Start monitoring service
      await AppUsageService.startMonitoring(timeLimitMinutes);
      
      // Save monitoring status
      await AppUsagePrefs().setMonitoringEnabled(true);
      
      emit(state.copyWith(
        isMonitoring: true,
        timeLimitMinutes: timeLimitMinutes,
        isLoading: false,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Stop monitoring
  Future<void> stopMonitoring() async {
    emit(state.copyWith(isLoading: true));
    
    try {
      // Stop monitoring service
      await AppUsageService.stopMonitoring();
      
      // Save monitoring status
      await AppUsagePrefs().setMonitoringEnabled(false);
      
      emit(state.copyWith(
        isMonitoring: false,
        isLoading: false,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Load today's usage data
  Future<void> loadTodayUsage() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final usageData = await AppUsageService.getAppUsage(startOfDay, now);
      
      // Sort by usage time descending
      usageData.sort((a, b) => b.usageTimeMinutes.compareTo(a.usageTimeMinutes));
      
      emit(state.copyWith(
        todayUsage: usageData,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
      ));
    }
  }

  /// Check permission status
  Future<void> checkPermission() async {
    try {
      final hasPermission = await AppUsageService.hasUsagePermission();
      
      emit(state.copyWith(
        hasPermission: hasPermission,
        clearError: true,
      ));
      
      // If permission was just granted, load usage data
      if (hasPermission && state.todayUsage.isEmpty) {
        await loadTodayUsage();
      }
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
      ));
    }
  }

  /// Reset daily notifications
  Future<void> resetDailyNotifications() async {
    try {
      final shouldReset = await AppUsagePrefs().shouldResetDaily();
      
      if (shouldReset) {
        await AppUsagePrefs().clearNotifiedApps();
      }
    } catch (e) {
      // Silent fail - not critical
    }
  }
}

