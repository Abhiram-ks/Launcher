import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/core/common/custom_appbar.dart';
import 'package:minilauncher/core/common/custom_snackbar.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/view_model/bloc/image_switch_cubit/image_switch_cubit.dart';
import 'package:minilauncher/features/view_model/bloc/root_bloc/root_bloc_dart_bloc.dart';

class SelectWallpaperView extends StatefulWidget {
  const SelectWallpaperView({super.key});

  @override
  State<SelectWallpaperView> createState() => _SelectWallpaperViewState();
}

class _SelectWallpaperViewState extends State<SelectWallpaperView> with TickerProviderStateMixin {
  List<String> availableWallpapers = [];
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _slideController, curve: Curves.easeOutCubic));

    availableWallpapers = List.generate(12, (index) => 'assets/wallpapers/${index + 1}.jpg');

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RootBloc, RootState>(
      listener: (context, state) {
        if (state is WallpaperLoadedState) {
          CustomSnackBar.show(context,
              message: 'Your new wallpaper is now active',
              backgroundColor: AppPalette.greenColor,
              textAlign: TextAlign.center);
          Future.delayed(const Duration(milliseconds: 1500), () {
            // ignore: use_build_context_synchronously
            if (mounted) Navigator.pop(context);
          });
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Wallpaper Gallery",
          isTitle: true,
          backgroundColor: AppPalette.blackColor,
        ),
        body: Stack(
          children: [
            BlocBuilder<WallpaperCubit, String>(
              builder: (context, selectedWallpaper) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(selectedWallpaper),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        AppTextStyleNotifier.instance.textColor.withValues(alpha: .4),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppPalette.blackColor.withValues(alpha: .7),
                    AppPalette.blackColor.withValues(alpha: .3),
                    AppPalette.blackColor.withValues(alpha: .8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: bodyPartOfSelectWallpaper(),
              ),
            ),
          ],
        ),

        floatingActionButton: BlocBuilder<WallpaperCubit, String>(
          builder: (context, selectedWallpaper) {
            final bloc = context.read<RootBloc>();
            final currentWallpaper = bloc.currentWallpaper;
            final isCurrentWallpaper = selectedWallpaper == currentWallpaper;

            return AnimatedScale(
              scale: isCurrentWallpaper ? 0.0 : 1.0,
              duration: const Duration(microseconds: 200),
              child: FloatingActionButton.extended(
                backgroundColor: AppPalette.orengeColor,
                icon: const Icon(CupertinoIcons.photo),
                label: const Text(
                  "Set as Wallpaper",
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                onPressed: isCurrentWallpaper ? null : _setWallpaper,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget bodyPartOfSelectWallpaper() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocBuilder<RootBloc, RootState>(
        builder: (context, state) {
          final bloc = context.read<RootBloc>();
          final currentWallpaper = bloc.currentWallpaper;

          return BlocBuilder<WallpaperCubit, String>(
            builder: (context, selectedWallpaper) {
              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.65,
                ),
                itemCount: availableWallpapers.length,
                itemBuilder: (context, index) {
                  final wallpaperPath = availableWallpapers[index];
                  final isSelected = selectedWallpaper == wallpaperPath;
                  final isCurrent = currentWallpaper == wallpaperPath;

                  return _buildWallpaperCard(   wallpaperPath, index, isSelected, isCurrent);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWallpaperCard(
      String wallpaperPath, int index, bool isSelected, bool isCurrent) {
    return GestureDetector(
      onTap: () {
        context.read<WallpaperCubit>().selectWallpaper(wallpaperPath);
      },
      child: Hero(
        tag: wallpaperPath,
        child: AnimatedContainer(
          duration: const Duration(microseconds: 100),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppTextStyleNotifier.instance.textColor.withValues(alpha: 1),
                  blurRadius: 20,
                  spreadRadius: 3,
                  offset: const Offset(0, 8),
                )
              else if (isCurrent)
                BoxShadow(
                  color: AppPalette.greenColor.withValues(alpha: .5),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                )
              else
                BoxShadow(
                  color: AppPalette.blackColor.withValues(alpha: .4),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  wallpaperPath,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppPalette.blackColor.withValues(alpha: .5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                if (isSelected || isCurrent)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        color: isCurrent
                            ? AppPalette.greenColor
                            : AppTextStyleNotifier.instance.textColor,
                        size: 22,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Text(
                     '${index + 1}',
                     style: TextStyle(
                      color: AppPalette.whiteColor,
                      fontWeight: FontWeight.bold
                     ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setWallpaper() {
    final selectedWallpaper = context.read<WallpaperCubit>().state;
    context
        .read<RootBloc>()
        .add(SetWallpaperEvent(wallpaperPath: selectedWallpaper));
  }
}



