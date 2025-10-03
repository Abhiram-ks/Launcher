import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/features/view_model/bloc/bloc/root_bloc_dart_bloc.dart';


class WallpaperBackground extends StatelessWidget {
  final Widget  child;
  const WallpaperBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RootBloc, RootState>(
      buildWhen: (previous, current) => current is WallpaperLoadedState,
      builder: (context, state) {
        String wallpaperPath = 'assets/wallpapers/1.jpg';
        
        if (state is WallpaperLoadedState) {
          wallpaperPath = state.currentWallpaper;
        } else {
          wallpaperPath = context.read<RootBloc>().currentWallpaper;         
        }

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(wallpaperPath),
              fit: BoxFit.cover,
            )
          ),
          child: child,
        );
      });
  }
}