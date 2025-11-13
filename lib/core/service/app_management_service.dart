import 'package:flutter/services.dart';

class AppManagementService {
  static const MethodChannel _channel = MethodChannel('app_management_service');

  /// Triggers the system uninstall dialog for the specified package
  /// 
  /// This will open Android's native uninstall screen where the user
  /// can confirm the uninstallation. The app cannot directly uninstall
  /// another app without user confirmation.
  /// 
  /// Example:
  /// ```dart
  /// await AppManagementService.uninstallApp('com.instagram.android');
  /// ```
  static Future<bool> uninstallApp(String packageName) async {
    try {
      final bool result = await _channel.invokeMethod('uninstallApp', {
        'packageName': packageName,
      });
      return result;
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Failed to uninstall app');
    } catch (e) {
      rethrow;
    }
  }

  /// Opens the system app info/settings screen for the specified package
  /// 
  /// This allows the user to view app details, permissions, storage usage,
  /// and other settings for the specified app.
  /// 
  /// Example:
  /// ```dart
  /// await AppManagementService.openAppInfo('com.telegram.messenger');
  /// ```
  static Future<bool> openAppInfo(String packageName) async {
    try {
      final bool result = await _channel.invokeMethod('openAppInfo', {
        'packageName': packageName,
      });
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }
}

