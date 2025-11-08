import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/core/constant/app_layout_type.dart';
import 'package:minilauncher/core/constant/storage_keys.dart';
import 'package:minilauncher/core/service/hive_storage.dart';

class LayoutState {
  final AppLayoutType layoutType;
  final int gridColumnCount;
  final bool isLoading;

  const LayoutState({
    required this.layoutType,
    required this.gridColumnCount,
    this.isLoading = false,
  });

  factory LayoutState.initial() {
    return const LayoutState(
      layoutType: AppLayoutType.list,
      gridColumnCount: 5,
      isLoading: true,
    );
  }

  LayoutState copyWith({
    AppLayoutType? layoutType,
    int? gridColumnCount,
    bool? isLoading,
  }) {
    return LayoutState(
      layoutType: layoutType ?? this.layoutType,
      gridColumnCount: gridColumnCount ?? this.gridColumnCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(LayoutState.initial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final layoutTypeString = HiveStorage.settingsBox.get(
        StorageKeys.layoutType,
        defaultValue: 'list',
      ) as String;
      
      final gridColumns = HiveStorage.settingsBox.get(
        StorageKeys.gridColumnCount,
        defaultValue: 5,
      ) as int;

      emit(state.copyWith(
        layoutType: AppLayoutType.fromString(layoutTypeString),
        gridColumnCount: gridColumns,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> setLayoutType(AppLayoutType layoutType) async {
    await HiveStorage.settingsBox.put(
      StorageKeys.layoutType,
      layoutType.storageValue,
    );
    emit(state.copyWith(layoutType: layoutType));
  }

  Future<void> setGridColumnCount(int columnCount) async {
    if (columnCount < 3 || columnCount > 6) return;
    
    await HiveStorage.settingsBox.put(
      StorageKeys.gridColumnCount,
      columnCount,
    );
    emit(state.copyWith(gridColumnCount: columnCount));
  }

  // Static method to get current layout type without cubit
  static AppLayoutType getLayoutType() {
    final layoutTypeString = HiveStorage.settingsBox.get(
      StorageKeys.layoutType,
      defaultValue: 'list',
    ) as String;
    return AppLayoutType.fromString(layoutTypeString);
  }

  // Static method to get current grid column count without cubit
  static int getGridColumnCount() {
    return HiveStorage.settingsBox.get(
      StorageKeys.gridColumnCount,
      defaultValue: 5,
    ) as int;
  }
}

