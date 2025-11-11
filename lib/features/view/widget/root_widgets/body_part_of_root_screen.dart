
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:minilauncher/features/view/screens/apps_screen/show_prioritized_apps.dart';
import 'package:minilauncher/features/view/widget/root_widgets/top_select_priority_view.dart';
import 'package:minilauncher/features/view_model/bloc/root_bloc/root_bloc_dart_bloc.dart';
import '../../../view_model/cubit/prioritized_scroll_cubit.dart';

Widget bodyPartOfRootScreen(BuildContext context) {
  return BlocBuilder<RootBloc, RootState>(
    buildWhen: (previous, current) => current is RootScreeBuildState,
    builder: (context, state) {
      if (state is SelectPriorityAppState) {
        return appsToSelectPriorityView(state, context);
      } else if (state is LoadPrioritizedAppsState) {
        return BlocProvider(
          create: (_) => PrioritizedScrollCubit(),
          child: ShowPrioritizedMainApps(state: state),
        );
      }
      return Center(
        child: Lottie.asset(
          'assets/energy_rocket.json',
          width: 150,
          height: 150,
        ),
      );
    },
  );
}