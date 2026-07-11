class CroatiaDestination {
  const CroatiaDestination({
    required this.id,
    required this.name,
    required this.regionId,
    required this.extraDistanceKm,
    required this.popular,
    this.croatiaExitGateId,
  });

  final String id;
  final String name;
  final String regionId;
  final double extraDistanceKm;
  final bool popular;
  final String? croatiaExitGateId;

  String get effectiveExitGateId =>
      croatiaExitGateId ?? _defaultExitGateId(regionId, id);

  factory CroatiaDestination.fromJson(Map<String, dynamic> json) {
    return CroatiaDestination(
      id: json['id'] as String,
      name: json['name'] as String,
      regionId: json['regionId'] as String,
      extraDistanceKm: (json['extraDistanceKm'] as num).toDouble(),
      popular: json['popular'] as bool? ?? false,
      croatiaExitGateId: json['croatiaExitGateId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'regionId': regionId,
      'extraDistanceKm': extraDistanceKm,
      'popular': popular,
      if (croatiaExitGateId != null) 'croatiaExitGateId': croatiaExitGateId,
    };
  }

  static String _defaultExitGateId(String regionId, String destinationId) {
    return switch (destinationId) {
      'trogir' || 'kastela' => 'vucevica',
      'omis' => 'sestanovac',
      'sukosan' || 'pakostane' || 'biograd_na_moru' => 'zadar_istok',
      'igrane' || 'zivogosce' || 'drvenik' || 'gradac' => 'ravca',
      _ => switch (regionId) {
          'istria' => 'pula',
          'kvarner' => 'rijeka',
          'zadar' => 'zadar',
          'sibenik' => 'sibenik',
          'split' => 'dugopolje',
          'makarska' => 'sestanovac',
          'ploce' => 'ploce',
          'dubrovnik' => 'ploce',
          _ => 'dugopolje',
        },
    };
  }
}
