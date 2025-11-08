import 'package:minilauncher/core/constant/storage_keys.dart';
import 'package:minilauncher/core/service/hive_storage.dart';

class PriorityAppsPrefs {
  //! let's create a singleton class
  PriorityAppsPrefs._privateConstructor();

  static final PriorityAppsPrefs instance = PriorityAppsPrefs._privateConstructor();

  factory PriorityAppsPrefs() {
    return instance;
  }

  String key = StorageKeys.priorityApps;

  Future<List<String>> getPriorityApps() async {
    final box = HiveStorage.settingsBox;
    final List<dynamic>? raw = box.get(key) as List<dynamic>?;
    return List<String>.from(raw ?? const <String>[]);
  }

  Future<void> setPriorityApps(List<String> apps) async {
    final box = HiveStorage.settingsBox;
    await box.put(key, apps);
  }

  Future<void> addPriorityApp(String app) async {
    List<String> apps =  await getPriorityApps();
    if (!apps.contains(app)) {
      apps.add(app);
      await setPriorityApps(apps);
    }
  }

  Future<void> removePriorityApp(String app) async {
    List<String> apps = await getPriorityApps();
    if (apps.contains(app)) {
      apps.remove(app);
      await setPriorityApps(apps);
    }
  }

  Future<bool> isPriorityApp(String app) async {
    List<String> apps = await getPriorityApps();
    return apps.contains(app);
  }

  Future<void> clearPriorityApps() async {
    final box = HiveStorage.settingsBox;
    await box.delete(key);
  }
}