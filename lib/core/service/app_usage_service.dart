import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:minilauncher/features/model/models/usage_model.dart';

class AppUsageService {
  static const MethodChannel _channel = MethodChannel('app_usage_service');

  /// Request PACKAGE_USAGE_STATS permission
  static Future<void> requestUsagePermission() async {
    try {
      await _channel.invokeMethod('requestUsagePermission');
    } on PlatformException catch (e) {
      throw Exception("Failed to request usage permission: '${e.message}'.");
    }
  }

  /// Check if PACKAGE_USAGE_STATS permission is granted
  static Future<bool> hasUsagePermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasUsagePermission');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception("Failed to check usage permission: '${e.message}'.");
    }
  }

  /// Get app usage data for a time range
  static Future<List<UsageModel>> getAppUsage(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final result = await _channel.invokeMethod<List>('getAppUsage', {
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime.millisecondsSinceEpoch,
      });

      if (result == null) {
        return [];
      }

      return result
          .map((item) => UsageModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on PlatformException catch (e) {
      throw Exception("Failed to get app usage: '${e.message}'.");
    }
  }

  /// Start background monitoring service
  static Future<void> startMonitoring(
    int timeLimitMinutes, {
    List<String>? priorityApps,
  }) async {
    try {
      debugPrint('========================================');
      debugPrint('🔧 APP_USAGE_SERVICE DEBUG:');
      debugPrint('⏱️ Time limit: $timeLimitMinutes minutes');
      debugPrint('📱 Priority apps: ${priorityApps?.length ?? 0}');
      if (priorityApps != null && priorityApps.isNotEmpty) {
        debugPrint('📦 Apps list:');
        for (var i = 0; i < priorityApps.length; i++) {
          debugPrint('  [$i] ${priorityApps[i]}');
        }
      } else {
        debugPrint('⚠️ No priority apps provided');
      }
      
      final args = <String, dynamic>{
        'timeLimitMinutes': timeLimitMinutes,
      };
      
      if (priorityApps != null && priorityApps.isNotEmpty) {
        args['priorityApps'] = priorityApps;
        debugPrint('✅ Adding priority apps to method channel args');
      }
      
      debugPrint('🚀 Invoking native startMonitoring...');
      debugPrint('========================================');
      await _channel.invokeMethod('startMonitoring', args);
      debugPrint('✅ Native startMonitoring completed');
    } on PlatformException catch (e) {
      debugPrint('❌ Failed to start monitoring: ${e.message}');
      throw Exception("Failed to start monitoring: '${e.message}'.");
    }
  }

  /// Stop background monitoring service
  static Future<void> stopMonitoring() async {
    try {
      await _channel.invokeMethod('stopMonitoring');
    } on PlatformException catch (e) {
      throw Exception("Failed to stop monitoring: '${e.message}'.");
    }
  }

  /// Get current foreground app
  static Future<String?> getCurrentForegroundApp() async {
    try {
      final result =
          await _channel.invokeMethod<String>('getCurrentForegroundApp');
      return result;
    } on PlatformException catch (e) {
      throw Exception("Failed to get foreground app: '${e.message}'.");
    }
  }

  /// Check if monitoring service is running
  static Future<bool> isMonitoringRunning() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('isMonitoringRunning');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Reset all notification tracking (both Flutter and Android)
  /// Call this when user changes time limit to allow new notifications
  static Future<void> resetNotifications() async {
    try {
      await _channel.invokeMethod('resetNotifications');
    } on PlatformException catch (e) {
      throw Exception("Failed to reset notifications: '${e.message}'.");
    }
  }

  /// Check if notification permission is granted (Android 13+)
  static Future<bool> hasNotificationPermission() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('hasNotificationPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception("Failed to check notification permission: '${e.message}'.");
    }
  }

  /// Request notification permission (Android 13+)
  static Future<void> requestNotificationPermission() async {
    try {
      await _channel.invokeMethod('requestNotificationPermission');
    } on PlatformException catch (e) {
      throw Exception(
          "Failed to request notification permission: '${e.message}'.");
    }
  }
}

