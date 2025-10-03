import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/view/screens/apps_screen/all_apps_screen.dart';
import 'package:minilauncher/features/view/screens/settings_screen/settings_screen.dart';
import 'package:minilauncher/features/view_model/bloc/bloc/root_bloc_dart_bloc.dart';

class ShowPrioritizedMainApps extends StatefulWidget {
  final LoadPrioritizedAppsState state;
  const ShowPrioritizedMainApps({super.key, required this.state});

  @override
  State<ShowPrioritizedMainApps> createState() =>
      _ShowPrioritizedMainAppsState();
}

class _ShowPrioritizedMainAppsState extends State<ShowPrioritizedMainApps> {
  final ScrollController _scrollController = ScrollController();
  bool _hasTriggered = false;
  bool _isLoadingApps = false; // Add this flag

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListenerV1);
  }

  Future<void> _scrollListenerV1() async {
    // Only trigger if we haven't already triggered and aren't currently loading
    if (!_hasTriggered && !_isLoadingApps) {
      // Check if we've scrolled to the trigger area (last item)
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;

        // Only trigger when we're near the bottom (trigger area)
        if (currentScroll >= maxScroll * 0.8) {
          // Adjust threshold as needed
          _isLoadingApps = true;
          context.read<RootBloc>().add(LoadAppsEvent());
        }
      }
    }
  }

  void _resetState() {
    setState(() {
      _hasTriggered = false;
      _isLoadingApps = false;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListenerV1);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onLongPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingView()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and Time Header
          GestureDetector(
            onLongPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingView()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 20),
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
                          color: AppPalette.greyColor,
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppPalette.whiteColor,
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(minutes: 15),
                        builder: (context, value, child) {
                          return AnimatedOpacity(
                            opacity: value < 0.8 ? 0.4 : (1 - value) * 2,
                            duration: const Duration(milliseconds: 300),
                            child: ConstantWidgets.hight20(context),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Apps List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: state.prioritizedApps.length + 1,
              itemBuilder: (context, index) {
                if (index < state.prioritizedApps.length) {
                  final app = state.prioritizedApps[index].app;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading:  (app is ApplicationWithIcon)
                            ? Image.memory(app.icon, width: 40, height: 40)
                            : const SizedBox(width: 40, height: 40),
                    title: Text(
                      app.appName,
                      style: const TextStyle(color: Colors.white60),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                    onTap: () {
                      context.read<RootBloc>().add(
                        LaunchAppEvent(packageName: app.packageName),
                      );
                    },
                  );
                }
                // Bottom trigger area
                else {
                  return BlocConsumer<RootBloc, RootState>(
                    buildWhen:
                        (previous, current) =>
                            (current is RootShowPrioritizedBuildState),
                    listenWhen:
                        (previous, current) =>
                            (current is RootShowPrioritizedBuildActionState),
                    listener: (BuildContext context, RootState state) async {
                      if (state is InitialAllAppsLoadedState &&
                          !_hasTriggered) {
                        _hasTriggered =
                            true; // Set this immediately to prevent multiple navigations

                        context.read<RootBloc>().add(
                          ResetToShowPrioritizedEvent(),
                        );
                        await _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );

                        // Small delay before navigation
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    AllAppsView(state: state),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return SlideTransition(
                                position: animation.drive(
                                  Tween(
                                    begin: const Offset(0.0, 1.0),
                                    end: Offset.zero,
                                  ),
                                ),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                          ),
                        ).then((_) => _resetState());
                      }
                    },
                    builder: (BuildContext context, RootState state) {
                      if (state is PreparedAllAppsLoadedState) {
                        return SizedBox.shrink();
                      }
                      return SizedBox(
                        height: screenHeight * 0.6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            (state is PreparingAllAppsLoadingState)
                                ? Column(
                                  children: [
                                    Transform.scale(
                                      scale: 0.3,
                                      child: CircularProgressIndicator(
                                        color: AppPalette.whiteColor,
                                        backgroundColor: AppPalette.greyColor,
                                        strokeWidth: 3,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Loading all apps...',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )
                                : AnimatedOpacity(
                                  opacity:
                                      (_hasTriggered || _isLoadingApps)
                                          ? 0.3
                                          : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Column(
                                    children: [
                                      TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0, end: 1),
                                        duration: const Duration(seconds: 2),
                                        builder: (context, value, child) {
                                          return Transform.translate(
                                            offset: Offset(0, -10 * value),
                                            child: Icon(
                                              Icons.keyboard_arrow_up,
                                              color: Colors.white30,
                                              size: 40,
                                            ),
                                          );
                                        },
                                      ),
                                      ConstantWidgets.hight20(context),
                                      Text(
                                        'Scroll up to load all apps',
                                        style: TextStyle(
                                          color: Colors.white30,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),

                            const Spacer(),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekday(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
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
}
