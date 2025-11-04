import 'package:bloc/bloc.dart';

class WallpaperCubit extends Cubit<String> {
  WallpaperCubit(super.initialWallpaper);

  void selectWallpaper(String wallpaperPath) {
    emit(wallpaperPath);
  }
}
