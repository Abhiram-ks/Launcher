import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/core/common/custom_snackbar.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/view/screens/apps_screen/show_prioritized_apps.dart';
import 'package:minilauncher/features/view/widget/wallpaper_background.dart';
import 'package:minilauncher/features/view_model/bloc/root_bloc/root_bloc_dart_bloc.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, 
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
            body: WallpaperBackground(
              child: bodyPartOfRootScreen(context),
            ),
          ),
      ),
    );
  }


}

  Widget bodyPartOfRootScreen(BuildContext context) {
    return BlocBuilder<RootBloc, RootState>(
      buildWhen: (previous, current) => current is RootScreeBuildState,
      builder: (context, state) {
         if (state is SelectPriorityAppState) {
          return appsToSelectPriorityView(state, context);
        } else if (state is LoadPrioritizedAppsState) {
          return ShowPrioritizedMainApps(state: state,);
        }
        return SizedBox();
      },
    );
  }
  
Widget appsToSelectPriorityView(SelectPriorityAppState state, BuildContext context) {
  const int maxSelectable = 13;

  return Scaffold(
    backgroundColor: Colors.transparent, 
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Padding(
          padding: EdgeInsets.only(top: 10, bottom: 15),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'Select Priority Apps (${state.selectedPackages.length})',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

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
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) {
                      if (!isSelected && state.selectedPackages.length >= maxSelectable) {
                        CustomSnackBar.show(context, message: 'You can only select up to 13 apps', textAlign: TextAlign.center);
                        return;
                      }
                      context.read<RootBloc>().add(TogglePriorityAppEvent(packageName));
                    },
                    title: Row(
                      children: [
                        if (app is ApplicationWithIcon)
                          Image.memory(app.icon, width: 40, height: 40),
                        ConstantWidgets.width20(context),
                        Flexible(
                          child: Text(
                            app.appName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppPalette.orengeColor,
                    checkColor: AppPalette.whiteColor,
                  );
                },
              );
            },
          ),
        ),
      ],
    ),

    // Floating Action Button (disabled if none or more than 4)
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: BlocBuilder<RootBloc, RootState>(
      buildWhen: (previous, current) => current is SelectPriorityAppState,
      builder: (context, state) {
        if (state is! SelectPriorityAppState) return const SizedBox();

        final bool canSave = state.selectedPackages.isNotEmpty &&
            state.selectedPackages.length <= maxSelectable;

        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 55,
          child: FloatingActionButton.extended(
            backgroundColor: canSave
                ? AppPalette.orengeColor
                : AppPalette.blackColor.withValues(alpha: 0.5),
            label: Text(
              canSave
                  ? 'Save'
                  : state.selectedPackages.isEmpty
                      ? 'Select at least one'
                      : 'Max 13 apps allowed',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: canSave
                ? () {
                    context.read<RootBloc>().add(
                          SavePriorityAppsEvent(
                            packageNames: state.selectedPackages.toList(),
                          ),
                        );
                  }
                : null,
          ),
        );
      },
    ),
  );
}
