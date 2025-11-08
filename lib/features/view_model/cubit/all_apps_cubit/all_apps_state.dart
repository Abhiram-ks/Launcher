
import 'package:minilauncher/features/model/models/app_model.dart';

class AllAppsState {
  final List<AppsModel> filteredApps;
  final Map<String, List<AppsModel>> groupedApps;
  final List<String> availableLetters;
  final bool showingAlphabetIndex;
  final String? currentDragLetter;
  final bool isDraggingAlphabet;

  const AllAppsState({
    required this.filteredApps,
    required this.groupedApps,
    required this.availableLetters,
    required this.showingAlphabetIndex,
    this.currentDragLetter,
    required this.isDraggingAlphabet,
  });

  factory AllAppsState.initial(List<AppsModel> allApps) {
    return AllAppsState(
      filteredApps: allApps,
      groupedApps: const {},
      availableLetters: const [],
      showingAlphabetIndex: true,
      currentDragLetter: null,
      isDraggingAlphabet: false,
    );
  }

  AllAppsState copyWith({
    List<AppsModel>? filteredApps,
    Map<String, List<AppsModel>>? groupedApps,
    List<String>? availableLetters,
    bool? showingAlphabetIndex,
    String? currentDragLetter,
    bool? isDraggingAlphabet,
    bool clearDragLetter = false,
  }) {
    return AllAppsState(
      filteredApps: filteredApps ?? this.filteredApps,
      groupedApps: groupedApps ?? this.groupedApps,
      availableLetters: availableLetters ?? this.availableLetters,
      showingAlphabetIndex: showingAlphabetIndex ?? this.showingAlphabetIndex,
      currentDragLetter: clearDragLetter ? null : currentDragLetter ?? this.currentDragLetter,
      isDraggingAlphabet: isDraggingAlphabet ?? this.isDraggingAlphabet,
    );
  }

}

