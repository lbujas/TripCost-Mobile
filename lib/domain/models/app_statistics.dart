class AppStatistics {
  const AppStatistics({
    required this.calculationsCount,
    required this.savedTripsCount,
  });

  final int calculationsCount;
  final int savedTripsCount;

  factory AppStatistics.defaults() {
    return const AppStatistics(
      calculationsCount: 0,
      savedTripsCount: 0,
    );
  }

  AppStatistics copyWith({
    int? calculationsCount,
    int? savedTripsCount,
  }) {
    return AppStatistics(
      calculationsCount: calculationsCount ?? this.calculationsCount,
      savedTripsCount: savedTripsCount ?? this.savedTripsCount,
    );
  }

  factory AppStatistics.fromJson(Map<String, dynamic> json) {
    return AppStatistics(
      calculationsCount: json['calculationsCount'] as int? ?? 0,
      savedTripsCount: json['savedTripsCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calculationsCount': calculationsCount,
      'savedTripsCount': savedTripsCount,
    };
  }
}
