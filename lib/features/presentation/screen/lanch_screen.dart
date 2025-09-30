import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/common/custom_appbar.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/presentation/bloc/apps_management/apps_management_bloc.dart';

class LauncherHome extends StatelessWidget {
  const LauncherHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppsManagementBloc()..add(LoadAppsEvent()),
      child: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(
            isTitle: true,
            title: 'App Management',
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.help_outline, color: AppPalette.greyColor),
              ),
            ],
          ),
          body: BlocBuilder<AppsManagementBloc, AppsManagementState>(
            builder: (context, state) {
              if (state is AppsManagementLoading) {
                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          backgroundColor: AppPalette.greyColor,
                          color: AppPalette.orengeColor,
                        ),
                      ),
                      ConstantWidgets.width20(context),
                      Text(
                        "Loading...",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppPalette.whiteColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is AppsManagementLoaded) {
                final apps = state.apps;
                return GridView.builder(
                  padding: const EdgeInsets.all(13),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    return GestureDetector(
                      onTap:
                          () => context.read<AppsManagementBloc>().add(
                            OpenAppEvent(app.packageName),
                          ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.memory(app.icon, height: 48, width: 48),
                          const SizedBox(height: 4),
                          Text(
                            app.appName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_outlined, size: 50),
                    Text(
                      'Request failed',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Request processing failed. Try again later.",
                      style: TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
