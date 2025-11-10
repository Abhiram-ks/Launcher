class UsageModel {
  final String appName;
  final String packageName;
  final int usageTimeMinutes;
  final DateTime lastUsed;

  UsageModel({
    required this.appName,
    required this.packageName,
    required this.usageTimeMinutes,
    required this.lastUsed,
  });

  factory UsageModel.fromJson(Map<String, dynamic> json) {
    return UsageModel(
      appName: json['appName'] as String? ?? '',
      packageName: json['packageName'] as String? ?? '',
      usageTimeMinutes: json['usageTimeMinutes'] as int? ?? 0,
      lastUsed: DateTime.fromMillisecondsSinceEpoch(
        json['lastUsed'] as int? ?? 0,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'packageName': packageName,
      'usageTimeMinutes': usageTimeMinutes,
      'lastUsed': lastUsed.millisecondsSinceEpoch,
    };
  }

  UsageModel copyWith({
    String? appName,
    String? packageName,
    int? usageTimeMinutes,
    DateTime? lastUsed,
  }) {
    return UsageModel(
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      usageTimeMinutes: usageTimeMinutes ?? this.usageTimeMinutes,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}

