import 'package:flutter/material.dart';
import 'package:minilauncher/features/view_model/cubit/all_apps_cubit/all_apps_state.dart';
import 'app_grid_item.dart';

/// Reusable grid view for grouped apps
Widget buildGroupedAppsGrid({
  required AllAppsState state,
  required ScrollController scrollController,
  required int columnCount,
  required Function(dynamic app) onAppTap,
  Function(dynamic app)? onAppLongPress,
  Widget Function(dynamic app)? buildGridItemOverlay,
}) {
  return GridView.builder(
    controller: scrollController,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columnCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85,
    ),
    itemCount: state.availableLetters.fold<int>(
      0,
      (sum, letter) => sum + (state.groupedApps[letter]?.length ?? 0),
    ),
    itemBuilder: (context, index) {
      // Find the app at this index
      int currentIndex = 0;
      for (final letter in state.availableLetters) {
        final apps = state.groupedApps[letter] ?? [];
        if (currentIndex + apps.length > index) {
          final appIndex = index - currentIndex;
          final appModel = apps[appIndex];
          return AppGridItem(
            app: appModel.app,
            onTap: onAppTap,
            onLongPress: onAppLongPress,
            buildOverlay: buildGridItemOverlay,
          );
        }
        currentIndex += apps.length;
      }
      return const SizedBox.shrink();
    },
  );
}

/// Reusable grid view for filtered apps
Widget buildFilteredAppsGrid({
  required AllAppsState state,
  required int columnCount,
  required Function(dynamic app) onAppTap,
  Function(dynamic app)? onAppLongPress,
  Widget Function(dynamic app)? buildGridItemOverlay,
}) {
  return GridView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columnCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85,
    ),
    itemCount: state.filteredApps.length,
    itemBuilder: (context, index) {
      final app = state.filteredApps[index].app;
      return AppGridItem(
        app: app,
        onTap: onAppTap,
        onLongPress: onAppLongPress,
        buildOverlay: buildGridItemOverlay,
      );
    },
  );
}

