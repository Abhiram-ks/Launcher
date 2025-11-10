import 'package:minilauncher/core/constant/storage_keys.dart';
import 'package:minilauncher/core/constant/usage_constants.dart';
import 'package:minilauncher/core/service/hive_storage.dart';

class AppUsagePrefs {
  AppUsagePrefs._privateConstructor();

  static final AppUsagePrefs instance = AppUsagePrefs._privateConstructor();

  factory AppUsagePrefs() {
    return instance;
  }

  static const int _defaultTimeLimit = UsageConstants.defaultTimeLimitMinutes;

  /// Save time limit in minutes
  Future<void> setTimeLimit(int minutes) async {
    final prefs = HiveStorage.settingsBox;
    await prefs.put(StorageKeys.screenTimeLimit, minutes);
  }

  /// Get time limit in minutes
  Future<int> getTimeLimit() async {
    final prefs = HiveStorage.settingsBox;
    final limit = prefs.get(StorageKeys.screenTimeLimit) as int?;
    return limit ?? _defaultTimeLimit;
  }

  /// Save monitoring enabled/disabled
  Future<void> setMonitoringEnabled(bool enabled) async {
    final prefs = HiveStorage.settingsBox;
    await prefs.put(StorageKeys.monitoringEnabled, enabled);
  }

  /// Get monitoring status
  Future<bool> isMonitoringEnabled() async {
    final prefs = HiveStorage.settingsBox;
    final enabled = prefs.get(StorageKeys.monitoringEnabled) as bool?;
    return enabled ?? false;
  }

  /// Save list of apps that were already notified today
  Future<void> markAppNotified(String packageName) async {
    final prefs = HiveStorage.settingsBox;
    final notifiedApps = await getNotifiedApps();
    
    if (!notifiedApps.contains(packageName)) {
      notifiedApps.add(packageName);
      await prefs.put(StorageKeys.notifiedApps, notifiedApps);
    }
  }

  /// Get list of notified apps
  Future<List<String>> getNotifiedApps() async {
    final prefs = HiveStorage.settingsBox;
    final notifiedApps = prefs.get(StorageKeys.notifiedApps) as List?;
    
    if (notifiedApps == null) {
      return [];
    }
    
    return notifiedApps.cast<String>();
  }

  /// Clear notified apps (reset daily)
  Future<void> clearNotifiedApps() async {
    final prefs = HiveStorage.settingsBox;
    await prefs.put(StorageKeys.notifiedApps, <String>[]);
    await _saveLastResetDate();
  }

  /// Check if we need to reset (new day)
  Future<bool> shouldResetDaily() async {
    final prefs = HiveStorage.settingsBox;
    final lastReset = prefs.get(StorageKeys.lastResetDate) as String?;
    
    if (lastReset == null) {
      return true;
    }
    
    final lastResetDate = DateTime.parse(lastReset);
    final today = DateTime.now();
    
    // Check if it's a new day
    return lastResetDate.day != today.day ||
           lastResetDate.month != today.month ||
           lastResetDate.year != today.year;
  }

  Future<void> _saveLastResetDate() async {
    final prefs = HiveStorage.settingsBox;
    await prefs.put(StorageKeys.lastResetDate, DateTime.now().toIso8601String());
  }

  /// Check if app was already notified today
  Future<bool> wasAppNotified(String packageName) async {
    final notifiedApps = await getNotifiedApps();
    return notifiedApps.contains(packageName);
  }
}

