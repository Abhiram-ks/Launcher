import 'dart:developer';

import 'package:bloc/bloc.dart';

import '../../../model/data/pick_image.dart';
part 'image_picker_event.dart';
part 'image_picker_state.dart';

class ImagePickerBloc extends Bloc<ImagePickerEvent, ImagePickerState> {
  final PickImageClass imagePicker;
  ImagePickerBloc({required this.imagePicker}) : super(ImagePickerInitial()) {
    on<PickImageAction>(_onPickImage);
    on<ClearImageAction>(_onClearImage);
  }


  Future<void> _onPickImage(
    PickImageAction event,
    Emitter<ImagePickerState> emit
  ) async  {
    emit(ImagePickerLoading());

    try {
      final String? imagePath = await imagePicker.pickImage();
      if (imagePath != null) {
        emit(ImagePickerLoaded(imagePath: imagePath));
      } else {
        emit(ImagePickerError(error: 'No image selected'));
      }
    } catch (e) {
      log('Error: $e');
      emit(ImagePickerError(error: e.toString()));
    }
  }


  void _onClearImage(
    ClearImageAction event,
    Emitter<ImagePickerState> emit
  ) {
    emit(ImagePickerInitial());
  }
}
