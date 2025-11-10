import 'package:minilauncher/features/model/models/usage_model.dart';

class UsageState {
  final bool isMonitoring;
  final bool hasPermission;
  final List<UsageModel> todayUsage;
  final int timeLimitMinutes;
  final bool isLoading;
  final String? error;

  const UsageState({
    required this.isMonitoring,
    required this.hasPermission,
    required this.todayUsage,
    required this.timeLimitMinutes,
    required this.isLoading,
    this.error,
  });

  factory UsageState.initial() {
    return const UsageState(
      isMonitoring: false,
      hasPermission: false,
      todayUsage: [],
      timeLimitMinutes: 15,
      isLoading: false,
      error: null,
    );
  }

  UsageState copyWith({
    bool? isMonitoring,
    bool? hasPermission,
    List<UsageModel>? todayUsage,
    int? timeLimitMinutes,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return UsageState(
      isMonitoring: isMonitoring ?? this.isMonitoring,
      hasPermission: hasPermission ?? this.hasPermission,
      todayUsage: todayUsage ?? this.todayUsage,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

