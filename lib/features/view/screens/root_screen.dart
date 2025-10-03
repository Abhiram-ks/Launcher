import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/view/screens/apps_screen/show_prioritized_apps.dart';
import 'package:minilauncher/features/view/widget/wallpaper_background.dart';
import 'package:minilauncher/features/view_model/bloc/bloc/root_bloc_dart_bloc.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, 
      child: SafeArea(
        child: Scaffold(
            appBar:  AppBar(
            forceMaterialTransparency: true,
            elevation: 0,
            title: Text('App Manager', style: TextStyle(color: AppPalette.whiteColor, fontSize: 14, fontWeight: FontWeight.bold)),
            centerTitle: true,
            
          ),
            body: WallpaperBackground(
              child: bodyPartOfRootScreen(context),
            ),
          ),
      ),
    );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10, left: 20, bottom: 20),
          child: Align(
            alignment: Alignment.center,
            child: Text('Select Priority Apps',
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
            itemCount: state.allApps.length,
            itemBuilder: (context, index) {
              final app = state.allApps[index].app;
              final packageName = app.packageName;
              return CheckboxListTile(
                value: state.selectedPackages.contains(packageName),
                onChanged: (_) {
                  context.read<RootBloc>().add(TogglePriorityAppEvent(packageName));
                },
                title: Row(
                  children: [
                    if (state.allApps[index].app is ApplicationWithIcon)
                      Image.memory(
                        (state.allApps[index].app as ApplicationWithIcon).icon,
                        width: 40,
                        height: 40,
                      ),
                    ConstantWidgets.width20(context),
                    Flexible(
                      child: Text(state.allApps[index].app.appName,
                        overflow: TextOverflow.clip,),
                    ),
                  ],
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppPalette.blackColor,
                checkColor: AppPalette.whiteColor,
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: state.selectedPackages.isEmpty ? AppPalette.blackColor.withValues(alpha: 0.5) :AppPalette.greyColor.withValues(alpha: 0.5) ,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              minimumSize: Size(MediaQuery.of(context).size.width, 50)
            ),
              onPressed: () {
                if (state.selectedPackages.isEmpty) return;
                context.read<RootBloc>().add(
                  SavePriorityAppsEvent(
                    packageNames: state.selectedPackages.toList(),
                  ),
                );
              },
              child: Text(
                state.selectedPackages.isEmpty ? 'Select Atleast one' : 'Save',
                style: TextStyle(
                  color: AppPalette.whiteColor,
                ),
              )
          ),
        )
      ],
    );
  }


  String _getWeekday(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}