import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/core/constant/app_layout_type.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/service/app_management_service.dart';
import 'package:minilauncher/core/widgets/app_search_field.dart';
import 'package:minilauncher/core/widgets/app_item_more_overlay.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/common/custom_appbar.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../view_model/cubit/layout_cubit.dart';
import '../../../view_model/cubit/all_apps_cubit/all_apps_cubit.dart';
import '../../../view_model/cubit/all_apps_cubit/all_apps_state.dart';
import '../../../view_model/bloc/root_bloc/root_bloc_dart_bloc.dart';
import '../../../model/data/appvalues.dart';
import '../../widget/wallpaper_background.dart';
import '../../widget/app_list_widgets/reusable_apps_list.dart';
import '../../widget/app_list_widgets/reusable_apps_grid.dart';

class AppManagementView extends StatefulWidget {
  const AppManagementView({super.key});

  @override
  State<AppManagementView> createState() => _AppManagementViewState();
}

class _AppManagementViewState extends State<AppManagementView> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map<String, GlobalKey> _sectionKeys = {};
  bool _needsRefresh = false;
  StreamSubscription<RootState>? _blocSubscription;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _needsRefresh) {
      _needsRefresh = false;
      _reloadAppsAfterUninstall();
    }
  }

  @override
  void didChangeMetrics() {
    // Required method for WidgetsBindingObserver - can be empty
  }

  void _onSearchChanged() {
    context.read<AllAppsCubit>().searchApps(_searchController.text);
  }

  void _reloadAppsAfterUninstall() {
    if (!mounted) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      AppValues.allApps = [];
      
      final rootBloc = context.read<RootBloc>();
    
      _blocSubscription?.cancel();
    
      _blocSubscription = rootBloc.stream.listen((rootState) {
        
        if (rootState is InitialAllAppsLoadedState && mounted) {
          _blocSubscription?.cancel();
          _blocSubscription = null;
        }
      });
      
      rootBloc.add(LoadAppsEvent());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _blocSubscription?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllAppsCubit, AllAppsState>(
        builder: (context, state) {
          // Update section keys when available letters change
          if (_sectionKeys.keys.toSet() != state.availableLetters.toSet()) {
            _sectionKeys = {
              for (String letter in state.availableLetters) letter: GlobalKey(),
            };
          }

          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: CustomAppBar(
              title: 'App Management',
              isTitle: true,
            ),
            body: WallpaperBackground(
        child: Stack(
          children: [
            Column(
              children: [
                AppSearchField(
                  controller: _searchController,
                  hintText: "Search apps to manage...",
                ),

                    Expanded(
                      child: BlocBuilder<LayoutCubit, LayoutState>(
                        builder: (context, layoutState) {
                          return layoutState.layoutType == AppLayoutType.list
                              ? buildGroupedAppsList(
                                  state: state,
                                  scrollController: _scrollController,
                                  sectionKeys: _sectionKeys,
                                  onAppTap: (app) {
                                    _showManagementOptions(context, app);
                                  },
                                  trailing: (app) => Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 10,
                                    color: AppTextStyleNotifier.instance.textColor,
                                  ),
                                )
                              : (state.showingAlphabetIndex
                                  ? buildGroupedAppsGrid(
                                      state: state,
                                      scrollController: _scrollController,
                                      columnCount: layoutState.gridColumnCount,
                                      onAppTap: (app) {
                                        _showManagementOptions(context, app);
                                      },
                                      onAppLongPress: (app) {
                                        _showManagementOptions(context, app);
                                      },
                                      buildGridItemOverlay: (app) => const AppItemMoreOverlay(),
                                    )
                                  : buildFilteredAppsGrid(
                                      state: state,
                                      columnCount: layoutState.gridColumnCount,
                                      onAppTap: (app) {
                                        _showManagementOptions(context, app);
                                      },
                                      onAppLongPress: (app) {
                                        _showManagementOptions(context, app);
                                      },
                                      buildGridItemOverlay: (app) => const AppItemMoreOverlay(),
                                    ));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showManagementOptions(BuildContext context, dynamic app) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          app.name,
          style: GoogleFonts.getFont(
            AppTextStyleNotifier.instance.fontFamily,
            textStyle: TextStyle(
              color: AppTextStyleNotifier.instance.textColor,
            ),
          ),
        ),
        message: Text(
         'Package Name: ${app.packageName}, Version: ${app.versionName ?? 'N/A'}+${app.versionCode ?? 'N/A'}',
          style: GoogleFonts.getFont(
            AppTextStyleNotifier.instance.fontFamily,
            textStyle: TextStyle(
              color: AppTextStyleNotifier.instance.textColor.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
 
            onPressed: () async {
              Navigator.pop(context);
              await AppManagementService.openAppInfo(app.packageName);
            },
            child:   Text(
                  'App Info',
                  style: GoogleFonts.getFont(
                    AppTextStyleNotifier.instance.fontFamily,
                    textStyle:  TextStyle(
                        color: AppTextStyleNotifier.instance.textColor,
                        fontSize: 14,
                    ),
                  ),
                  textAlign: TextAlign.center,  
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IntivitualAppHandleScreen(packageName: app.packageName, appName: app.name ?? 'N/A'),
                ),
              );
            },
            child:  Text(
                  '${app.name ?? 'N/A'} Management',
                  style: GoogleFonts.getFont(
                    AppTextStyleNotifier.instance.fontFamily,
                    textStyle:  TextStyle(
                        color: AppTextStyleNotifier.instance.textColor,
                        fontSize: 14,
                    ),
                  ),
                  textAlign: TextAlign.center,  
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              // Set flag to refresh when app resumes
              _needsRefresh = true;
              // Trigger Android's uninstall dialog
              await AppManagementService.uninstallApp(app.packageName);
            },
            isDestructiveAction: true,
            child:  Text(
                    'Uninstall',
                  style: GoogleFonts.getFont(
                    AppTextStyleNotifier.instance.fontFamily,
                    textStyle:  TextStyle(
                        color: AppPalette.redColor,
                        fontSize: 14,
                    ),
                  ),
                  textAlign: TextAlign.center,  
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          isDefaultAction: true,
          child:  Text(
                    'Cancel',
                  style: GoogleFonts.getFont(
                    AppTextStyleNotifier.instance.fontFamily,
                    textStyle:  TextStyle(
                        color:  AppTextStyleNotifier.instance.textColor,
                        fontSize: 14,
                    ),
                  ),
                  textAlign: TextAlign.center,  
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
        ),
      ),
    );
  }
}
