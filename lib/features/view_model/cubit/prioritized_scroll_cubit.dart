import 'package:bloc/bloc.dart';

class PrioritizedScrollState {
  final bool hasTriggered;
  final bool isLoading;
  const PrioritizedScrollState({required this.hasTriggered, required this.isLoading});

  const PrioritizedScrollState.initial() : this(hasTriggered: false, isLoading: false);

  PrioritizedScrollState copyWith({bool? hasTriggered, bool? isLoading}) {
    return PrioritizedScrollState(
      hasTriggered: hasTriggered ?? this.hasTriggered,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PrioritizedScrollCubit extends Cubit<PrioritizedScrollState> {
  PrioritizedScrollCubit() : super(const PrioritizedScrollState.initial());

  void markLoading() => emit(state.copyWith(isLoading: true));
  void markTriggered() => emit(state.copyWith(hasTriggered: true));
  void reset() => emit(const PrioritizedScrollState.initial());
}


