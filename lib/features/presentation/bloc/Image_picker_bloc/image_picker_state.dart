part of 'image_picker_bloc.dart';

abstract class ImagePickerState {}

final class ImagePickerInitial extends ImagePickerState {}

final class ImagePickerLoading extends ImagePickerState {}

final class ImagePickerLoaded extends ImagePickerState {
  final String imagePath;
  ImagePickerLoaded({required this.imagePath});
}

final class ImagePickerError extends ImagePickerState {
  final String error;
  ImagePickerError({required this.error});
}