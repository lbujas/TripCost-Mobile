class RouteDistanceEstimate {
  const RouteDistanceEstimate({
    required this.originCityId,
    required this.croatiaDestinationId,
    required this.routeId,
    required this.oneWayDistanceKm,
  });

  final String originCityId;
  final String croatiaDestinationId;
  final String routeId;
  final double oneWayDistanceKm;

  factory RouteDistanceEstimate.fromJson(Map<String, dynamic> json) {
    return RouteDistanceEstimate(
      originCityId: json['originCityId'] as String,
      croatiaDestinationId: json['croatiaDestinationId'] as String,
      routeId: json['routeId'] as String,
      oneWayDistanceKm: (json['oneWayDistanceKm'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originCityId': originCityId,
      'croatiaDestinationId': croatiaDestinationId,
      'routeId': routeId,
      'oneWayDistanceKm': oneWayDistanceKm,
    };
  }
}
