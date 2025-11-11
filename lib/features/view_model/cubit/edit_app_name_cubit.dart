import 'package:flutter_bloc/flutter_bloc.dart';

class EditAppNameCubit extends Cubit<bool> {
  EditAppNameCubit() : super(false);

  void toggle() {
    emit(!state);
  }

  void hide() {
    emit(false);
  }

  void show() {
    emit(true);
  }
}

