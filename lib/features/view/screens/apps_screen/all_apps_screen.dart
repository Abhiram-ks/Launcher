import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/constant/app_layout_type.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/view/widget/wallpaper_background.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/features/view_model/bloc/root_bloc/root_bloc_dart_bloc.dart';
import 'package:minilauncher/features/view_model/cubit/all_apps_cubit/all_apps_cubit.dart';
import 'package:minilauncher/features/view_model/cubit/all_apps_cubit/all_apps_state.dart';
import 'package:minilauncher/features/view_model/cubit/layout_cubit.dart';
import 'package:minilauncher/features/view/widget/app_list_widgets/reusable_apps_list.dart';
import 'package:minilauncher/features/view/widget/app_list_widgets/reusable_apps_grid.dart';
import 'package:google_fonts/google_fonts.dart';

class AllAppsView extends StatefulWidget {
  final InitialAllAppsLoadedState state;

  const AllAppsView({super.key, required this.state});

  @override
  State<AllAppsView> createState() => _AllAppsViewState();
}

class _AllAppsViewState extends State<AllAppsView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _dragEndTimer;
  Map<String, GlobalKey> _sectionKeys = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    context.read<AllAppsCubit>().searchApps(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _dragEndTimer?.cancel();
    super.dispose();
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
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
          body: WallpaperBackground(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstantWidgets.hight50(context),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 20,
                        right: 20,
                      ),
                      child: StreamBuilder<DateTime>(
                        stream: Stream.periodic(
                          const Duration(seconds: 1),
                          (_) => DateTime.now(),
                        ),
                        initialData: DateTime.now(),
                        builder: (context, snapshot) {
                          final now = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_getWeekday(now.weekday)}, ${now.day} ${_getMonth(now.month)}',
                                style: GoogleFonts.getFont(
                                  AppTextStyleNotifier.instance.fontFamily,
                                  textStyle: TextStyle(
                                    color:
                                        AppTextStyleNotifier
                                            .instance
                                            .textColor,
                                    fontSize: 30,
                                    fontWeight:
                                        AppTextStyleNotifier
                                            .instance
                                            .fontWeight,
                                  ),
                                ),
                              ),
                              Text(
                                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second}',
                                style: GoogleFonts.getFont(
                                  AppTextStyleNotifier.instance.fontFamily,
                                  textStyle: TextStyle(
                                    color: AppTextStyleNotifier.instance.textColor,
                                    fontSize: 25,
                                    fontWeight:  AppTextStyleNotifier.instance.fontWeight,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
        
                    /// Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search apps...",
                          hintStyle: GoogleFonts.getFont(
                            AppTextStyleNotifier.instance.fontFamily,
                            color: AppTextStyleNotifier.instance.textColor,
                          ),
                          filled: true,
                          fillColor: Colors.white10,
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTextStyleNotifier.instance.textColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
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
                                    // Launch the app
                                    context.read<RootBloc>().add(
                                      LaunchAppEvent(packageName: app.packageName),
                                    );
                                  },
                                )
                              : (state.showingAlphabetIndex
                                  ? buildGroupedAppsGrid(
                                      state: state,
                                      scrollController: _scrollController,
                                      columnCount: layoutState.gridColumnCount,
                                      onAppTap: (app) {
                                        context.read<RootBloc>().add(
                                          LaunchAppEvent(packageName: app.packageName),
                                        );
                                      },
                                    )
                                  : buildFilteredAppsGrid(
                                      state: state,
                                      columnCount: layoutState.gridColumnCount,
                                      onAppTap: (app) {
                                        context.read<RootBloc>().add(
                                          LaunchAppEvent(packageName: app.packageName),
                                        );
                                      },
                                    ));
                        },
                      ),
                    ),
                  ],
                ),
        
                // Alphabetical Index Sidebar (only show in list view)
                if (state.showingAlphabetIndex)
                  BlocBuilder<LayoutCubit, LayoutState>(
                    builder: (context, layoutState) {
                      if (layoutState.layoutType == AppLayoutType.list) {
                        return _buildAlphabetIndex(state);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildAlphabetIndex(AllAppsState state) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    // Hide alphabet index when keyboard is visible (cleanest solution)
    if (isKeyboardVisible) {
      return const SizedBox.shrink();
    }
    return Positioned(
      right: 4,
      top: MediaQuery.of(context).size.height * 0.25,
      bottom: MediaQuery.of(context).size.height * 0.1,
      child: GestureDetector(
        onPanStart: (details) {
          _handleAlphabetInteraction(
            state,
            details.localPosition,
            isDrag: true,
          );
          HapticFeedback.selectionClick();
        },
        onPanUpdate: (details) {
          _handleAlphabetInteraction(
            state,
            details.localPosition,
            isDrag: true,
          );
        },
        onPanEnd: (details) {
          _dragEndTimer?.cancel();
          _dragEndTimer = Timer(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.read<AllAppsCubit>().stopDraggingAlphabet();
            }
          });
        },
        onTapDown: (details) {
          // Handle tap immediately for better responsiveness
          _handleAlphabetInteraction(
            state,
            details.localPosition,
            isDrag: false,
          );
        },
        child: SizedBox(
          width: 24,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildAlphabetItems(state),
          ),
        ),
      ),
    );
  }

  // **Unified Touch Handling Method**
  void _handleAlphabetInteraction(
    AllAppsState state,
    Offset position, {
    required bool isDrag,
  }) {
    final containerHeight = MediaQuery.of(context).size.height * 0.65;

    // Get all available letters in correct order (including #)
    final allLetters = [
      '#',
      ...List.generate(26, (i) => String.fromCharCode(65 + i)),
    ];

    // Find which letter was touched
    final itemHeight = containerHeight / allLetters.length;
    final tappedIndex = (position.dy / itemHeight).floor().clamp(
      0,
      allLetters.length - 1,
    );
    final tappedLetter = allLetters[tappedIndex];

    // Only proceed if this letter has apps
    if (state.availableLetters.contains(tappedLetter) &&
        state.groupedApps[tappedLetter] != null &&
        state.groupedApps[tappedLetter]!.isNotEmpty) {
      // Update UI state
      if (isDrag) {
        context.read<AllAppsCubit>().updateDragLetter(tappedLetter);
      } else {
        context.read<AllAppsCubit>().startDraggingAlphabet(tappedLetter);
      }

      // Jump to letter
      _jumpToLetter(tappedLetter);

      // Haptic feedback
      HapticFeedback.selectionClick();

      // Auto-hide for taps
      if (!isDrag) {
        Timer(const Duration(milliseconds: 800), () {
          if (mounted) {
            context.read<AllAppsCubit>().stopDraggingAlphabet();
          }
        });
      }
    }
  }

  // **Build Alphabet Items Dynamically**
  List<Widget> _buildAlphabetItems(AllAppsState state) {
    final allLetters = [
      '#',
      ...List.generate(26, (i) => String.fromCharCode(65 + i)),
    ];

    return allLetters.map((letter) {
      final isAvailable = state.availableLetters.contains(letter);
      final isActive = state.currentDragLetter == letter;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          vertical: isActive ? 4 : 2,
          horizontal: isActive ? 6 : 2,
        ),
        decoration:
            isActive
                ? BoxDecoration(
                  color: AppTextStyleNotifier.instance.textColor.withValues(
                    alpha: .6,
                  ),
                  borderRadius: BorderRadius.circular(8),
                )
                : null,
        child: Text(
          letter,
          style: TextStyle(
            color:
                isAvailable
                    ? (isActive
                        ? AppPalette.whiteColor
                        : AppTextStyleNotifier.instance.textColor.withValues(
                          alpha: 0.7,
                        ))
                    : AppPalette.whiteColor.withValues(alpha: .15),
            fontSize: isActive ? 14 : 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w300,
          ),
        ),
      );
    }).toList();
  }

  void _jumpToLetter(String letter) {
    final sectionKey = _sectionKeys[letter];

    // Method 1: Try Scrollable.ensureVisible (most reliable)
    if (sectionKey?.currentContext != null) {
      try {
        Scrollable.ensureVisible(
          sectionKey!.currentContext!,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: 0.1, // Small offset from top
        );
        return;
      } catch (e) {
        // Fall through to backup method
      }
    }

    // Method 2: Backup using ListView index
    final state = context.read<AllAppsCubit>().state;
    final letterIndex = state.availableLetters.indexOf(letter);
    if (letterIndex != -1 && _scrollController.hasClients) {
      // Calculate approximate position
      double targetPosition = 0;
      for (int i = 0; i < letterIndex; i++) {
        final prevLetter = state.availableLetters[i];
        final appsCount = state.groupedApps[prevLetter]?.length ?? 0;
        targetPosition += 48 + (appsCount * 72) + 16; // Header + apps + spacing
      }

      final maxScroll = _scrollController.position.maxScrollExtent;
      final clampedPosition = targetPosition.clamp(0.0, maxScroll);

      _scrollController.animateTo(
        clampedPosition,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }
  }
}