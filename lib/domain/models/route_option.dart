class RouteOption {
  const RouteOption({
    required this.id,
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.durationMinutes,
    required this.countryCodes,
    this.croatiaEntryGateId,
  });

  final String id;
  final String origin;
  final String destination;
  final double distanceKm;
  final int durationMinutes;
  final List<String> countryCodes;
  final String? croatiaEntryGateId;

  /// One-way route distance. [distanceKm] in JSON stores one-way distance.
  double get oneWayDistanceKm => distanceKm;

  factory RouteOption.fromJson(Map<String, dynamic> json) {
    return RouteOption(
      id: json['id'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      durationMinutes: json['durationMinutes'] as int,
      countryCodes: (json['countryCodes'] as List<dynamic>)
          .map((code) => code as String)
          .toList(),
      croatiaEntryGateId: json['croatiaEntryGateId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'origin': origin,
      'destination': destination,
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'countryCodes': countryCodes,
      if (croatiaEntryGateId != null)
        'croatiaEntryGateId': croatiaEntryGateId,
    };
  }
}
