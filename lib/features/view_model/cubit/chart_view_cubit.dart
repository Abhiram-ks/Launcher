import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChartViewState {
  final String selectedView;
  final List<String> viewOptions;
  final DateTime selectedDate;

  const ChartViewState({
    required this.selectedView,
    required this.viewOptions,
    required this.selectedDate,
  });

  ChartViewState copyWith({
    String? selectedView,
    List<String>? viewOptions,
    DateTime? selectedDate,
  }) {
    return ChartViewState(
      selectedView: selectedView ?? this.selectedView,
      viewOptions: viewOptions ?? this.viewOptions,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  String get formattedDate {
    return DateFormat('E, dd MMM').format(selectedDate);
  }
}

class ChartViewCubit extends Cubit<ChartViewState> {
  ChartViewCubit()
      : super(ChartViewState(
          selectedView: 'Bar Chart',
          viewOptions: const ['Bar Chart', 'Graph'],
          selectedDate: DateTime.now(),
        ));

  void selectView(String view) {
    emit(state.copyWith(selectedView: view));
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void previousDay() {
    final newDate = state.selectedDate.subtract(const Duration(days: 1));
    emit(state.copyWith(selectedDate: newDate));
  }

  void nextDay() {
    final newDate = state.selectedDate.add(const Duration(days: 1));
    emit(state.copyWith(selectedDate: newDate));
  }

  void reset() {
    emit(ChartViewState(
      selectedView: 'Bar Chart',
      viewOptions: const ['Bar Chart', 'Graph'],
      selectedDate: DateTime.now(),
    ));
  }
}

