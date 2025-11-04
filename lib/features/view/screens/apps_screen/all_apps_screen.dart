import 'dart:async';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/model/models/app_model.dart';
import 'package:minilauncher/features/view/widget/wallpaper_background.dart';
import 'package:minilauncher/features/view_model/bloc/root_bloc/root_bloc_dart_bloc.dart';

class AllAppsView extends StatefulWidget {
  final InitialAllAppsLoadedState state;

  const AllAppsView({super.key, required this.state});

  @override
  State<AllAppsView> createState() => _AllAppsViewState();
}

class _AllAppsViewState extends State<AllAppsView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<AppsModel> _filteredApps = [];
  Map<String, List<AppsModel>> groupedApps = {};
  List<String> availableLetters = [];
  Map<String, double> letterPositions = {};

  bool _showingAlphabetIndex = true;
  String? _currentDragLetter;
  bool isDraggingAlphabet = false;
  Timer? _dragEndTimer;
  final Map<String, GlobalKey> _sectionKeys = {};

  @override
  void initState() {
    super.initState();
    _filteredApps = widget.state.allApps;
    _searchController.addListener(_onSearchChanged);
    _groupAppsAlphabetically();
  }

  void _createSectionKeys() {
    _sectionKeys.clear();
    for (String letter in availableLetters) {
      _sectionKeys[letter] = GlobalKey();
    }
  }

  void _groupAppsAlphabetically() {
    groupedApps.clear();
    availableLetters.clear();

    // Group apps by first letter with proper validation
    for (var appModel in _filteredApps) {
      final appName = appModel.app.appName.trim();
      if (appName.isEmpty) continue;

      final firstChar = appName[0].toUpperCase();

      // Only include letters A-Z, skip numbers and special characters
      if (firstChar.codeUnitAt(0) < 65 || firstChar.codeUnitAt(0) > 90) {
        const specialKey = '#';
        if (!groupedApps.containsKey(specialKey)) {
          groupedApps[specialKey] = [];
          availableLetters.add(specialKey);
        }
        groupedApps[specialKey]!.add(appModel);
      } else {
        if (!groupedApps.containsKey(firstChar)) {
          groupedApps[firstChar] = [];
          availableLetters.add(firstChar);
        }
        groupedApps[firstChar]!.add(appModel);
      }
    }

    // Sort letters (# will come first, then A-Z)
    availableLetters.sort((a, b) {
      if (a == '#') return -1;
      if (b == '#') return 1;
      return a.compareTo(b);
    });

    // Sort apps within each group
    groupedApps.forEach((key, value) {
      value.sort((a, b) => a.app.appName.compareTo(b.app.appName));
    });

    // Create section keys AFTER grouping
    _createSectionKeys();
  }

  void _calculateLetterPositions() {
    letterPositions.clear();
    double currentPosition = 0;

    for (String letter in availableLetters) {
      letterPositions[letter] = currentPosition;

      // Validate that the group actually exists and has apps
      final appsInGroup = groupedApps[letter];
      if (appsInGroup != null && appsInGroup.isNotEmpty) {
        // Header height (40) + apps count * item height (72) + spacing
        currentPosition += 40 + (appsInGroup.length * 72) + 8;
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredApps = widget.state.allApps;
        _showingAlphabetIndex = true;
      } else {
        _filteredApps =
            widget.state.allApps
                .where(
                  (appInfo) =>
                      appInfo.app.appName.toLowerCase().contains(query),
                )
                .toList();
        _showingAlphabetIndex = false;
      }
      _groupAppsAlphabetically();
      _calculateLetterPositions();
    });
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
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: WallpaperBackground(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 30,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w300,
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
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white10,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child:
                        _showingAlphabetIndex
                            ? _buildGroupedAppsList()
                            : _buildFilteredAppsList(),
                  ),
                ],
              ),

              // Alphabetical Index Sidebar
              if (_showingAlphabetIndex) _buildAlphabetIndex(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedAppsList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(right: 30),
      itemCount: availableLetters.length,
      itemBuilder: (context, index) {
        final letter = availableLetters[index];
        final apps = groupedApps[letter]!;

        return Column(
          key: _sectionKeys[letter],
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                letter,
                style: TextStyle(
                  color: AppPalette.whiteColor.withValues(alpha: .7),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                ),
              ),
            ),
            // Apps in this section
            ...apps.map((appModel) {
              final app = appModel.app;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading:
                    (app is ApplicationWithIcon)
                        ? Image.memory(app.icon, width: 40, height: 40)
                        : SizedBox(width: 40, height: 40),
                title: Text(
                  app.appName,
                  style: const TextStyle(color: Colors.white60),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                onTap: () {
                  context.read<RootBloc>().add(
                    LaunchAppEvent(packageName: app.packageName),
                  );
                },
              );
            }),
            ConstantWidgets.hight20(context),
          ],
        );
      },
    );
  }

  Widget _buildFilteredAppsList() {
    return ListView.builder(
      itemCount: _filteredApps.length,
      itemBuilder: (context, index) {
        final app = _filteredApps[index].app;
        return ListTile(
          title: Row(
            children: [
              if (app is ApplicationWithIcon)
                Image.memory(app.icon, width: 40, height: 40),
              ConstantWidgets.width20(context),
              Text(app.appName, style: const TextStyle(color: Colors.white60)),
            ],
          ),
          onTap: () {
            context.read<RootBloc>().add(
              LaunchAppEvent(packageName: app.packageName),
            );
          },
        );
      },
    );
  }

  Widget _buildAlphabetIndex() {
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
          setState(() {
            isDraggingAlphabet = true;
          });
          _handleAlphabetInteraction(details.localPosition, isDrag: true);
          HapticFeedback.selectionClick();
        },
        onPanUpdate: (details) {
          _handleAlphabetInteraction(details.localPosition, isDrag: true);
        },
        onPanEnd: (details) {
          _dragEndTimer?.cancel();
          _dragEndTimer = Timer(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _currentDragLetter = null;
                isDraggingAlphabet = false;
              });
            }
          });
        },
        onTapDown: (details) {
          // Handle tap immediately for better responsiveness
          _handleAlphabetInteraction(details.localPosition, isDrag: false);
        },
        child: SizedBox(
          width: 24,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildAlphabetItems(),
          ),
        ),
      ),
    );
  }

  // **Unified Touch Handling Method**
  void _handleAlphabetInteraction(Offset position, {required bool isDrag}) {
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
    if (availableLetters.contains(tappedLetter) &&
        groupedApps[tappedLetter] != null &&
        groupedApps[tappedLetter]!.isNotEmpty) {
      // Update UI state
      setState(() {
        _currentDragLetter = tappedLetter;
        if (!isDrag) {
          isDraggingAlphabet = true;
        }
      });

      // Jump to letter
      _jumpToLetter(tappedLetter);

      // Haptic feedback
      HapticFeedback.selectionClick();

      // Auto-hide for taps
      if (!isDrag) {
        Timer(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _currentDragLetter = null;
              isDraggingAlphabet = false;
            });
          }
        });
      }
    }
  }

  // **Build Alphabet Items Dynamically**
  List<Widget> _buildAlphabetItems() {
    final allLetters = [
      '#',
      ...List.generate(26, (i) => String.fromCharCode(65 + i)),
    ];

    return allLetters.map((letter) {
      final isAvailable = availableLetters.contains(letter);
      final isActive = _currentDragLetter == letter;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          vertical: isActive ? 4 : 2,
          horizontal: isActive ? 6 : 2,
        ),
        decoration:  isActive
                ? BoxDecoration(
                  color: AppPalette.orengeColor.withValues(alpha: .6),
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
                        : AppPalette.whiteColor.withValues(alpha: 0.7))
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
    final letterIndex = availableLetters.indexOf(letter);
    if (letterIndex != -1 && _scrollController.hasClients) {
      // Calculate approximate position
      double targetPosition = 0;
      for (int i = 0; i < letterIndex; i++) {
        final prevLetter = availableLetters[i];
        final appsCount = groupedApps[prevLetter]?.length ?? 0;
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



