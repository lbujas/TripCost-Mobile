import 'package:travel_cost_planner_europe/domain/models/car.dart';
import 'package:travel_cost_planner_europe/domain/models/route_option.dart';
import 'package:travel_cost_planner_europe/domain/models/selected_vignette.dart';
import 'package:travel_cost_planner_europe/domain/models/toll.dart';
import 'package:travel_cost_planner_europe/domain/models/trip_direction.dart';

class TripResult {
  const TripResult({
    this.id,
    this.createdAt,
    required this.route,
    required this.car,
    required this.tripDays,
    required this.peopleCount,
    required this.tripDirection,
    required this.oneWayDistanceKm,
    required this.extraDistanceKm,
    required this.totalDistanceKm,
    this.originCityId,
    this.originCityName,
    this.estimatedOneWayDistanceKm,
    this.customOneWayDistanceKm,
    this.usedCustomDistance = false,
    this.croatiaDestinationId,
    this.croatiaDestinationName,
    this.croatiaRegionId,
    this.croatiaTollDestination,
    this.croatiaEntryGateId,
    this.croatiaEntryGateName,
    this.croatiaExitGateId,
    this.croatiaExitGateName,
    this.croatiaTollAccuracy,
    this.croatiaTollSource,
    this.croatiaTollBaseGateName,
    this.croatiaTollFallbackUsed = false,
    this.croatiaDestinationExtraKm = 0,
    required this.fuelLiters,
    required this.fuelCostPln,
    required this.vignetteCostPln,
    this.tollMultiplier = 1,
    this.oneWayTollCostPln = 0,
    this.totalTollCostPln = 0,
    required this.tollCostPln,
    required this.totalCostPln,
    required this.costPerPersonPln,
    this.selectedVignettes = const [],
    this.selectedTolls = const [],
  });

  final String? id;
  final DateTime? createdAt;
  final RouteOption route;
  final Car car;
  final int tripDays;
  final int peopleCount;
  final TripDirection tripDirection;
  final double oneWayDistanceKm;
  final double extraDistanceKm;
  final double totalDistanceKm;
  final String? originCityId;
  final String? originCityName;
  final double? estimatedOneWayDistanceKm;
  final double? customOneWayDistanceKm;
  final bool usedCustomDistance;
  final String? croatiaDestinationId;
  final String? croatiaDestinationName;
  final String? croatiaRegionId;
  final String? croatiaTollDestination;
  final String? croatiaEntryGateId;
  final String? croatiaEntryGateName;
  final String? croatiaExitGateId;
  final String? croatiaExitGateName;
  final String? croatiaTollAccuracy;
  final String? croatiaTollSource;
  final String? croatiaTollBaseGateName;
  final bool croatiaTollFallbackUsed;
  final double croatiaDestinationExtraKm;
  final double fuelLiters;
  final double fuelCostPln;
  final double vignetteCostPln;
  final int tollMultiplier;
  final double oneWayTollCostPln;
  final double totalTollCostPln;
  final double tollCostPln;
  final double totalCostPln;
  final double costPerPersonPln;
  final List<SelectedVignette> selectedVignettes;
  final List<Toll> selectedTolls;

  double get totalExtraKm => extraDistanceKm + croatiaDestinationExtraKm;

  double get resolvedOneWayTollCostPln => oneWayTollCostPln > 0
      ? oneWayTollCostPln
      : (tollMultiplier > 0 ? tollCostPln / tollMultiplier : tollCostPln);

  double get resolvedTotalTollCostPln =>
      totalTollCostPln > 0 ? totalTollCostPln : tollCostPln;

  TripResult copyWith({
    String? id,
    DateTime? createdAt,
    RouteOption? route,
    Car? car,
    int? tripDays,
    int? peopleCount,
    TripDirection? tripDirection,
    double? oneWayDistanceKm,
    double? extraDistanceKm,
    double? totalDistanceKm,
    String? originCityId,
    String? originCityName,
    double? estimatedOneWayDistanceKm,
    double? customOneWayDistanceKm,
    bool? usedCustomDistance,
    String? croatiaDestinationId,
    String? croatiaDestinationName,
    String? croatiaRegionId,
    String? croatiaTollDestination,
    String? croatiaEntryGateId,
    String? croatiaEntryGateName,
    String? croatiaExitGateId,
    String? croatiaExitGateName,
    String? croatiaTollAccuracy,
    String? croatiaTollSource,
    String? croatiaTollBaseGateName,
    bool? croatiaTollFallbackUsed,
    double? croatiaDestinationExtraKm,
    double? fuelLiters,
    double? fuelCostPln,
    double? vignetteCostPln,
    int? tollMultiplier,
    double? oneWayTollCostPln,
    double? totalTollCostPln,
    double? tollCostPln,
    double? totalCostPln,
    double? costPerPersonPln,
    List<SelectedVignette>? selectedVignettes,
    List<Toll>? selectedTolls,
  }) {
    return TripResult(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      route: route ?? this.route,
      car: car ?? this.car,
      tripDays: tripDays ?? this.tripDays,
      peopleCount: peopleCount ?? this.peopleCount,
      tripDirection: tripDirection ?? this.tripDirection,
      oneWayDistanceKm: oneWayDistanceKm ?? this.oneWayDistanceKm,
      extraDistanceKm: extraDistanceKm ?? this.extraDistanceKm,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      originCityId: originCityId ?? this.originCityId,
      originCityName: originCityName ?? this.originCityName,
      estimatedOneWayDistanceKm:
          estimatedOneWayDistanceKm ?? this.estimatedOneWayDistanceKm,
      customOneWayDistanceKm:
          customOneWayDistanceKm ?? this.customOneWayDistanceKm,
      usedCustomDistance: usedCustomDistance ?? this.usedCustomDistance,
      croatiaDestinationId: croatiaDestinationId ?? this.croatiaDestinationId,
      croatiaDestinationName:
          croatiaDestinationName ?? this.croatiaDestinationName,
      croatiaRegionId: croatiaRegionId ?? this.croatiaRegionId,
      croatiaTollDestination:
          croatiaTollDestination ?? this.croatiaTollDestination,
      croatiaEntryGateId: croatiaEntryGateId ?? this.croatiaEntryGateId,
      croatiaEntryGateName: croatiaEntryGateName ?? this.croatiaEntryGateName,
      croatiaExitGateId: croatiaExitGateId ?? this.croatiaExitGateId,
      croatiaExitGateName: croatiaExitGateName ?? this.croatiaExitGateName,
      croatiaTollAccuracy: croatiaTollAccuracy ?? this.croatiaTollAccuracy,
      croatiaTollSource: croatiaTollSource ?? this.croatiaTollSource,
      croatiaTollBaseGateName:
          croatiaTollBaseGateName ?? this.croatiaTollBaseGateName,
      croatiaTollFallbackUsed:
          croatiaTollFallbackUsed ?? this.croatiaTollFallbackUsed,
      croatiaDestinationExtraKm:
          croatiaDestinationExtraKm ?? this.croatiaDestinationExtraKm,
      fuelLiters: fuelLiters ?? this.fuelLiters,
      fuelCostPln: fuelCostPln ?? this.fuelCostPln,
      vignetteCostPln: vignetteCostPln ?? this.vignetteCostPln,
      tollMultiplier: tollMultiplier ?? this.tollMultiplier,
      oneWayTollCostPln: oneWayTollCostPln ?? this.oneWayTollCostPln,
      totalTollCostPln: totalTollCostPln ?? this.totalTollCostPln,
      tollCostPln: tollCostPln ?? this.tollCostPln,
      totalCostPln: totalCostPln ?? this.totalCostPln,
      costPerPersonPln: costPerPersonPln ?? this.costPerPersonPln,
      selectedVignettes: selectedVignettes ?? this.selectedVignettes,
      selectedTolls: selectedTolls ?? this.selectedTolls,
    );
  }

  factory TripResult.fromJson(Map<String, dynamic> json) {
    final route = RouteOption.fromJson(json['route'] as Map<String, dynamic>);
    final tripDirection = json['tripDirection'] != null
        ? TripDirection.fromJson(json['tripDirection'] as String)
        : TripDirection.roundTrip;
    final oneWayDistanceKm =
        (json['oneWayDistanceKm'] as num?)?.toDouble() ?? route.oneWayDistanceKm;
    final extraDistanceKm =
        (json['extraDistanceKm'] as num?)?.toDouble() ?? 0;
    final croatiaDestinationExtraKm =
        (json['croatiaDestinationExtraKm'] as num?)?.toDouble() ?? 0;
    final totalDistanceKm = (json['totalDistanceKm'] as num?)?.toDouble() ??
        _legacyTotalDistanceKm(
          oneWayDistanceKm: oneWayDistanceKm,
          tripDirection: tripDirection,
          extraDistanceKm: extraDistanceKm + croatiaDestinationExtraKm,
        );

    return TripResult(
      id: json['id'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      route: route,
      car: Car.fromJson(json['car'] as Map<String, dynamic>),
      tripDays: json['tripDays'] as int? ?? 1,
      peopleCount: json['peopleCount'] as int? ?? 1,
      tripDirection: tripDirection,
      oneWayDistanceKm: oneWayDistanceKm,
      extraDistanceKm: extraDistanceKm,
      totalDistanceKm: totalDistanceKm,
      originCityId: json['originCityId'] as String?,
      originCityName: json['originCityName'] as String?,
      estimatedOneWayDistanceKm:
          (json['estimatedOneWayDistanceKm'] as num?)?.toDouble(),
      customOneWayDistanceKm:
          (json['customOneWayDistanceKm'] as num?)?.toDouble(),
      usedCustomDistance: json['usedCustomDistance'] as bool? ?? false,
      croatiaDestinationId: json['croatiaDestinationId'] as String?,
      croatiaDestinationName: json['croatiaDestinationName'] as String?,
      croatiaRegionId: json['croatiaRegionId'] as String?,
      croatiaTollDestination: json['croatiaTollDestination'] as String?,
      croatiaEntryGateId: json['croatiaEntryGateId'] as String?,
      croatiaEntryGateName: json['croatiaEntryGateName'] as String?,
      croatiaExitGateId: json['croatiaExitGateId'] as String?,
      croatiaExitGateName: json['croatiaExitGateName'] as String?,
      croatiaTollAccuracy: json['croatiaTollAccuracy'] as String?,
      croatiaTollSource: json['croatiaTollSource'] as String?,
      croatiaTollBaseGateName: json['croatiaTollBaseGateName'] as String?,
      croatiaTollFallbackUsed: json['croatiaTollFallbackUsed'] as bool? ?? false,
      croatiaDestinationExtraKm: croatiaDestinationExtraKm,
      fuelLiters: (json['fuelLiters'] as num?)?.toDouble() ?? 0,
      fuelCostPln: (json['fuelCostPln'] as num?)?.toDouble() ?? 0,
      vignetteCostPln: (json['vignetteCostPln'] as num?)?.toDouble() ?? 0,
      tollMultiplier: json['tollMultiplier'] as int? ??
          (tripDirection == TripDirection.roundTrip ? 2 : 1),
      oneWayTollCostPln: _parseOneWayTollCostPln(json, tripDirection),
      totalTollCostPln: _parseTotalTollCostPln(json),
      tollCostPln: _parseTotalTollCostPln(json),
      totalCostPln: (json['totalCostPln'] as num?)?.toDouble() ?? 0,
      costPerPersonPln: (json['costPerPersonPln'] as num?)?.toDouble() ?? 0,
      selectedVignettes: _parseVignettes(json['selectedVignettes']),
      selectedTolls: _parseTolls(json['selectedTolls']),
    );
  }

  static List<SelectedVignette> _parseVignettes(Object? raw) {
    if (raw is! List<dynamic>) {
      return const [];
    }

    final vignettes = <SelectedVignette>[];
    for (final item in raw) {
      try {
        vignettes.add(
          SelectedVignette.fromJson(Map<String, dynamic>.from(item as Map)),
        );
      } catch (_) {
        continue;
      }
    }

    return vignettes;
  }

  static List<Toll> _parseTolls(Object? raw) {
    if (raw is! List<dynamic>) {
      return const [];
    }

    final tolls = <Toll>[];
    for (final item in raw) {
      try {
        tolls.add(Toll.fromJson(Map<String, dynamic>.from(item as Map)));
      } catch (_) {
        continue;
      }
    }

    return tolls;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      'route': route.toJson(),
      'car': car.toJson(),
      'tripDays': tripDays,
      'peopleCount': peopleCount,
      'tripDirection': tripDirection.toJson(),
      'oneWayDistanceKm': oneWayDistanceKm,
      'extraDistanceKm': extraDistanceKm,
      'totalDistanceKm': totalDistanceKm,
      if (originCityId != null) 'originCityId': originCityId,
      if (originCityName != null) 'originCityName': originCityName,
      if (estimatedOneWayDistanceKm != null)
        'estimatedOneWayDistanceKm': estimatedOneWayDistanceKm,
      if (customOneWayDistanceKm != null)
        'customOneWayDistanceKm': customOneWayDistanceKm,
      'usedCustomDistance': usedCustomDistance,
      if (croatiaDestinationId != null)
        'croatiaDestinationId': croatiaDestinationId,
      if (croatiaDestinationName != null)
        'croatiaDestinationName': croatiaDestinationName,
      if (croatiaRegionId != null) 'croatiaRegionId': croatiaRegionId,
      if (croatiaTollDestination != null)
        'croatiaTollDestination': croatiaTollDestination,
      if (croatiaEntryGateId != null)
        'croatiaEntryGateId': croatiaEntryGateId,
      if (croatiaEntryGateName != null)
        'croatiaEntryGateName': croatiaEntryGateName,
      if (croatiaExitGateId != null)
        'croatiaExitGateId': croatiaExitGateId,
      if (croatiaExitGateName != null)
        'croatiaExitGateName': croatiaExitGateName,
      if (croatiaTollAccuracy != null)
        'croatiaTollAccuracy': croatiaTollAccuracy,
      if (croatiaTollSource != null) 'croatiaTollSource': croatiaTollSource,
      if (croatiaTollBaseGateName != null)
        'croatiaTollBaseGateName': croatiaTollBaseGateName,
      if (croatiaTollFallbackUsed) 'croatiaTollFallbackUsed': true,
      'croatiaDestinationExtraKm': croatiaDestinationExtraKm,
      'fuelLiters': fuelLiters,
      'fuelCostPln': fuelCostPln,
      'vignetteCostPln': vignetteCostPln,
      if (tollMultiplier != 1) 'tollMultiplier': tollMultiplier,
      if (oneWayTollCostPln > 0) 'oneWayTollCostPln': oneWayTollCostPln,
      if (totalTollCostPln > 0) 'totalTollCostPln': totalTollCostPln,
      'tollCostPln': tollCostPln,
      'totalCostPln': totalCostPln,
      'costPerPersonPln': costPerPersonPln,
      'selectedVignettes':
          selectedVignettes.map((vignette) => vignette.toJson()).toList(),
      'selectedTolls': selectedTolls.map((toll) => toll.toJson()).toList(),
    };
  }

  static double _parseTotalTollCostPln(Map<String, dynamic> json) {
    return (json['totalTollCostPln'] as num?)?.toDouble() ??
        (json['tollCostPln'] as num?)?.toDouble() ??
        0;
  }

  static double _parseOneWayTollCostPln(
    Map<String, dynamic> json,
    TripDirection tripDirection,
  ) {
    final stored = (json['oneWayTollCostPln'] as num?)?.toDouble();
    if (stored != null) {
      return stored;
    }

    final total = _parseTotalTollCostPln(json);
    if (total == 0) {
      return 0;
    }

    final multiplier = json['tollMultiplier'] as int? ??
        (tripDirection == TripDirection.roundTrip ? 2 : 1);
    return multiplier > 0 ? total / multiplier : total;
  }

  static double _legacyTotalDistanceKm({
    required double oneWayDistanceKm,
    required TripDirection tripDirection,
    required double extraDistanceKm,
  }) {
    return switch (tripDirection) {
      TripDirection.oneWay => oneWayDistanceKm + extraDistanceKm,
      TripDirection.roundTrip => oneWayDistanceKm * 2 + extraDistanceKm,
    };
  }
}
