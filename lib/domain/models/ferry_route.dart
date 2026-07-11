class FerryRoute {
  const FerryRoute({
    required this.id,
    required this.countryCode,
    required this.fromPortId,
    required this.fromPortName,
    required this.toPortId,
    required this.toPortName,
    this.islandName,
    required this.operatorName,
    this.durationMinutes,
    required this.canCarryVehicles,
    this.purchaseUrl,
    this.sourceUrl,
    this.notes,
  });

  final String id;
  final String countryCode;
  final String fromPortId;
  final String fromPortName;
  final String toPortId;
  final String toPortName;
  final String? islandName;
  final String operatorName;
  final int? durationMinutes;
  final bool canCarryVehicles;
  final String? purchaseUrl;
  final String? sourceUrl;
  final String? notes;

  factory FerryRoute.fromJson(Map<String, dynamic> json) {
    return FerryRoute(
      id: json['id'] as String,
      countryCode: json['countryCode'] as String,
      fromPortId: json['fromPortId'] as String,
      fromPortName: json['fromPortName'] as String,
      toPortId: json['toPortId'] as String,
      toPortName: json['toPortName'] as String,
      islandName: json['islandName'] as String?,
      operatorName: json['operatorName'] as String,
      durationMinutes: json['durationMinutes'] as int?,
      canCarryVehicles: json['canCarryVehicles'] as bool,
      purchaseUrl: json['purchaseUrl'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'countryCode': countryCode,
      'fromPortId': fromPortId,
      'fromPortName': fromPortName,
      'toPortId': toPortId,
      'toPortName': toPortName,
      if (islandName != null) 'islandName': islandName,
      'operatorName': operatorName,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      'canCarryVehicles': canCarryVehicles,
      if (purchaseUrl != null) 'purchaseUrl': purchaseUrl,
      if (sourceUrl != null) 'sourceUrl': sourceUrl,
      if (notes != null) 'notes': notes,
    };
  }
}