import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/features/model/models/app_model.dart';
import 'all_apps_state.dart';

class AllAppsCubit extends Cubit<AllAppsState> {
  final List<AppsModel> allApps;

  AllAppsCubit(this.allApps) : super(AllAppsState.initial(allApps)) {
    _groupAppsAlphabetically();
  }

  void searchApps(String query) {
    final lowerQuery = query.toLowerCase().trim();

    if (lowerQuery.isEmpty) {
      emit(state.copyWith(
        filteredApps: allApps,
        showingAlphabetIndex: true,
      ));
    } else {
      final filtered = allApps
          .where((appInfo) => appInfo.app.name.toLowerCase().contains(lowerQuery))
          .toList();

      emit(state.copyWith(
        filteredApps: filtered,
        showingAlphabetIndex: false,
      ));
    }

    _groupAppsAlphabetically();
  }

  void _groupAppsAlphabetically() {
    final Map<String, List<AppsModel>> grouped = {};
    final List<String> letters = [];

    // Group apps by first letter with proper validation
    for (var appModel in state.filteredApps) {
      final appName = appModel.app.name.trim();
      if (appName.isEmpty) continue;

      final firstChar = appName[0].toUpperCase();

      // Only include letters A-Z, skip numbers and special characters
      if (firstChar.codeUnitAt(0) < 65 || firstChar.codeUnitAt(0) > 90) {
        const specialKey = '#';
        if (!grouped.containsKey(specialKey)) {
          grouped[specialKey] = [];
          letters.add(specialKey);
        }
        grouped[specialKey]!.add(appModel);
      } else {
        if (!grouped.containsKey(firstChar)) {
          grouped[firstChar] = [];
          letters.add(firstChar);
        }
        grouped[firstChar]!.add(appModel);
      }
    }

    // Sort letters (# will come first, then A-Z)
    letters.sort((a, b) {
      if (a == '#') return -1;
      if (b == '#') return 1;
      return a.compareTo(b);
    });

    // Sort apps within each group
    grouped.forEach((key, value) {
      value.sort((a, b) => a.app.name.compareTo(b.app.name));
    });

    emit(state.copyWith(
      groupedApps: grouped,
      availableLetters: letters,
    ));
  }

  void startDraggingAlphabet(String letter) {
    emit(state.copyWith(
      currentDragLetter: letter,
      isDraggingAlphabet: true,
    ));
  }

  void updateDragLetter(String letter) {
    emit(state.copyWith(
      currentDragLetter: letter,
    ));
  }

  void stopDraggingAlphabet() {
    emit(state.copyWith(
      clearDragLetter: true,
      isDraggingAlphabet: false,
    ));
  }
}

