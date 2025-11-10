import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenTimerState {
  final int hours;
  final int minutes;

  const ScreenTimerState({
    required this.hours,
    required this.minutes,
  });

  ScreenTimerState copyWith({
    int? hours,
    int? minutes,
  }) {
    return ScreenTimerState(
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
    );
  }
}

class ScreenTimerCubit extends Cubit<ScreenTimerState> {
  ScreenTimerCubit() : super(const ScreenTimerState(hours: 0, minutes: 15));

  void updateHours(int hours) {
    emit(state.copyWith(hours: hours));
  }

  void updateMinutes(int minutes) {
    emit(state.copyWith(minutes: minutes));
  }

  void reset() {
    emit(const ScreenTimerState(hours: 0, minutes: 15));
  }
}

