import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/core/constant/storage_keys.dart';
import 'package:minilauncher/core/service/hive_storage.dart';

class DoubleTapCubit extends Cubit<bool> {
  DoubleTapCubit() : super(true) {
    _loadSetting();
  }

  void _loadSetting() {
    final enabled = HiveStorage.settingsBox.get(
      StorageKeys.doubleTapEnabled,
      defaultValue: true,
    ) as bool;
    emit(enabled);
  }

  Future<void> toggle() async {
    final newValue = !state;
    await HiveStorage.settingsBox.put(StorageKeys.doubleTapEnabled, newValue);
    emit(newValue);
  }

  static bool getDoubleTapEnabled() {
    return HiveStorage.settingsBox.get(
      StorageKeys.doubleTapEnabled,
      defaultValue: true,
    ) as bool;
  }
}

