part of 'image_picker_bloc.dart';

abstract class ImagePickerEvent {}

final class PickImageAction extends ImagePickerEvent {}

final class ClearImageAction extends ImagePickerEvent {}