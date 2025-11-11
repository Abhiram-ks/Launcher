import 'dart:io';
import 'dart:typed_data';
import 'package:installed_apps/app_info.dart';
import 'package:minilauncher/features/model/data/app_customization_prefs.dart';

/// Helper class to get customized app data
class AppCustomizationHelper {
  /// Get customized app name (returns custom name if exists, otherwise original)
  static String getCustomizedAppName(String packageName, String originalName) {
    final customName = AppCustomizationPrefs.instance.getNewAppName(packageName);
    return customName ?? originalName;
  }

  /// Get customized app icon data
  /// Returns Uint8List if custom icon exists, otherwise returns original icon
  static Future<Uint8List?> getCustomizedAppIcon(
    String packageName,
    Uint8List? originalIcon,
  ) async {
    final customIconPath = AppCustomizationPrefs.instance.getNewAppIcon(packageName);
    
    if (customIconPath != null) {
      try {
        final file = File(customIconPath);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      } catch (e) {
        // If custom icon file doesn't exist, fall back to original
        return originalIcon;
      }
    }
    
    return originalIcon;
  }

  /// Get customized app icon path (for file-based display)
  static String? getCustomizedAppIconPath(String packageName) {
    return AppCustomizationPrefs.instance.getNewAppIcon(packageName);
  }

  /// Check if app has customizations
  static bool hasCustomizations(String packageName) {
    final customization = AppCustomizationPrefs.instance.getAppCustomization(packageName);
    return customization != null;
  }
}

/// Model for app with customizations applied
class CustomizedAppData {
  final AppInfo app;
  final String displayName;
  final Uint8List? displayIcon;
  final String? customIconPath;
  final bool hasCustomName;
  final bool hasCustomIcon;

  CustomizedAppData({
    required this.app,
    required this.displayName,
    this.displayIcon,
    this.customIconPath,
    required this.hasCustomName,
    required this.hasCustomIcon,
  });
}

