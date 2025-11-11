import 'dart:async';
import 'package:minilauncher/core/constant/storage_keys.dart';
import 'package:minilauncher/core/service/hive_storage.dart';

class AppCustomizationPrefs {
  AppCustomizationPrefs._privateConstructor() {
    _initStream();
  }

  static final AppCustomizationPrefs instance = AppCustomizationPrefs._privateConstructor();

  factory AppCustomizationPrefs() {
    return instance;
  }

  static const String _key = StorageKeys.appCustomizations;
  
  final _customizationsController = StreamController<Map<String, Map<String, dynamic>>>.broadcast();
  StreamSubscription? _hiveSubscription;

  void _initStream() {
    // Listen to Hive box changes
    final box = HiveStorage.settingsBox;
    _hiveSubscription = box.watch(key: _key).listen((event) {
      final customizations = _getAllCustomizations();
      _customizationsController.add(customizations);
    });
    
    // Emit initial value
    _customizationsController.add(_getAllCustomizations());
  }

  /// Stream of all customizations
  Stream<Map<String, Map<String, dynamic>>> get customizationsStream => _customizationsController.stream;

  /// Stream for specific package name
  Stream<Map<String, dynamic>?> watchCustomization(String packageName) {
    return customizationsStream.map((all) => all[packageName]);
  }

  /// Get all customizations
  Map<String, Map<String, dynamic>> _getAllCustomizations() {
    final box = HiveStorage.settingsBox;
    final Map<dynamic, dynamic>? customizations = box.get(_key) as Map<dynamic, dynamic>?;
    
    if (customizations == null) return {};
    
    return Map<String, Map<String, dynamic>>.from(
      customizations.map((key, value) => MapEntry(
        key.toString(),
        Map<String, dynamic>.from(value as Map),
      )),
    );
  }

  void dispose() {
    _hiveSubscription?.cancel();
    _customizationsController.close();
  }

  /// Save app customization (icon and/or name)
  Future<void> saveAppCustomization({
    required String appPackageName,
    String? newAppName,
    String? newAppIcon,
  }) async {
    final box = HiveStorage.settingsBox;
    
    // Get existing customizations map
    final Map<dynamic, dynamic>? existing = box.get(_key) as Map<dynamic, dynamic>?;
    final Map<String, Map<String, dynamic>> customizations = 
        existing != null 
            ? Map<String, Map<String, dynamic>>.from(
                existing.map((key, value) => MapEntry(key.toString(), Map<String, dynamic>.from(value as Map)))
              )
            : {};

    // Update or create entry for this app
    customizations[appPackageName] = {
      'app_package_name': appPackageName,
      if (newAppName != null) 'new_app_name': newAppName,
      if (newAppIcon != null) 'new_app_icon': newAppIcon,
    };

    await box.put(_key, customizations);
  }

  /// Get app customization
  Map<String, dynamic>? getAppCustomization(String appPackageName) {
    final box = HiveStorage.settingsBox;
    final Map<dynamic, dynamic>? customizations = box.get(_key) as Map<dynamic, dynamic>?;
    
    if (customizations == null) return null;
    
    final appData = customizations[appPackageName];
    if (appData == null) return null;
    
    return Map<String, dynamic>.from(appData as Map);
  }

  /// Get new app name for package
  String? getNewAppName(String appPackageName) {
    final customization = getAppCustomization(appPackageName);
    return customization?['new_app_name'] as String?;
  }

  /// Get new app icon path for package
  String? getNewAppIcon(String appPackageName) {
    final customization = getAppCustomization(appPackageName);
    return customization?['new_app_icon'] as String?;
  }

  /// Remove app customization
  Future<void> removeAppCustomization(String appPackageName) async {
    final box = HiveStorage.settingsBox;
    final Map<dynamic, dynamic>? customizations = box.get(_key) as Map<dynamic, dynamic>?;
    
    if (customizations == null) return;
    
    final Map<String, dynamic> updated = Map<String, dynamic>.from(
      customizations.map((key, value) => MapEntry(key.toString(), value))
    );
    
    updated.remove(appPackageName);
    await box.put(_key, updated);
  }

  /// Clear all customizations
  Future<void> clearAllCustomizations() async {
    final box = HiveStorage.settingsBox;
    await box.delete(_key);
  }
}

