import 'package:hive_flutter/hive_flutter.dart';

import 'package:minilauncher/core/constant/storage_keys.dart';

class HiveStorage {
  HiveStorage._();

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(StorageKeys.boxSettings);
  }

  static Box get settingsBox => Hive.box(StorageKeys.boxSettings);
}


