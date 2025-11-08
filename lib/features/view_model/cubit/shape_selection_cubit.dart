import 'package:bloc/bloc.dart';
import 'package:minilauncher/core/constant/app_icon_shape.dart';
import 'package:minilauncher/features/model/data/app_icon_shape_prefs.dart';

class ShapeSelectionState {
  final bool isLoading;
  final AppIconShape shape;

  const ShapeSelectionState({
    required this.isLoading,
    required this.shape,
  });

  factory ShapeSelectionState.loading() => const ShapeSelectionState(
        isLoading: true,
        shape: AppIconShape.squircle,
      );

  ShapeSelectionState copyWith({
    bool? isLoading,
    AppIconShape? shape,
  }) {
    return ShapeSelectionState(
      isLoading: isLoading ?? this.isLoading,
      shape: shape ?? this.shape,
    );
  }
}

class ShapeSelectionCubit extends Cubit<ShapeSelectionState> {
  ShapeSelectionCubit() : super(ShapeSelectionState.loading());

  Future<void> load() async {
    final shape = await AppIconShapePrefs().getShape();
    emit(ShapeSelectionState(
      isLoading: false,
      shape: shape,
    ));
  }

  Future<void> setShape(AppIconShape shape) async {
    await AppIconShapePrefs().setShape(shape);
    emit(state.copyWith(shape: shape));
  }
}

