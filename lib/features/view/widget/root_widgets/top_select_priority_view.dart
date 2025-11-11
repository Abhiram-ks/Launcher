import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/features/view/widget/root_widgets/root_widgets.dart';
import '../../../view_model/bloc/root_bloc/root_bloc_dart_bloc.dart';

/// Screen for selecting priority apps to be displayed on the home screen
Widget appsToSelectPriorityView(
  SelectPriorityAppState state,
  BuildContext context,
) {
  const int maxSelectable = 10;

  return Scaffold(
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header showing selection count
        PriorityAppHeader(
          selectedCount: state.selectedPackages.length,
        ),

        // List of apps to select from
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: state.allApps.length,
            itemBuilder: (context, index) {
              final app = state.allApps[index].app;
              final packageName = app.packageName;

              return BlocSelector<RootBloc, RootState, bool>(
                selector: (state) {
                  if (state is SelectPriorityAppState) {
                    return state.selectedPackages.contains(packageName);
                  }
                  return false;
                },
                builder: (context, isSelected) {
                  return PriorityAppItem(
                    app: app,
                    isSelected: isSelected,
                    currentSelectionCount: state.selectedPackages.length,
                    maxSelectable: maxSelectable,
                  );
                },
              );
            },
          ),
        ),
      ],
    ),

    // Save button at bottom
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: BlocBuilder<RootBloc, RootState>(
      buildWhen: (previous, current) => current is SelectPriorityAppState,
      builder: (context, state) {
        if (state is! SelectPriorityAppState) return const SizedBox();

        return PrioritySaveButton(
          selectedCount: state.selectedPackages.length,
          selectedPackages: state.selectedPackages.toList(),
          maxSelectable: maxSelectable,
        );
      },
    ),
  );
}
