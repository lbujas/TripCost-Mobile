import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_sort_mode.dart';

class PackingListSettings {
  const PackingListSettings({
    this.defaultSortMode = PackingSortMode.custom,
    this.showPackedItems = true,
    this.showProgress = true,
    this.remindersEnabled = false,
  });

  final PackingSortMode defaultSortMode;
  final bool showPackedItems;
  final bool showProgress;
  final bool remindersEnabled;

  factory PackingListSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PackingListSettings();
    }

    return PackingListSettings(
      defaultSortMode: PackingSortMode.fromJson(json['defaultSortMode']),
      showPackedItems: json['showPackedItems'] as bool? ?? true,
      showProgress: json['showProgress'] as bool? ?? true,
      remindersEnabled: json['remindersEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultSortMode': defaultSortMode.toJson(),
      'showPackedItems': showPackedItems,
      'showProgress': showProgress,
      'remindersEnabled': remindersEnabled,
    };
  }
}
