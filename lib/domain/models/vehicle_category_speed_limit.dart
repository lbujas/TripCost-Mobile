/// Speed limits keyed by country, app vehicle type, and official category (v2 data).
class VehicleCategorySpeedLimit {
  const VehicleCategorySpeedLimit({
    required this.countryCode,
    required this.vehicleType,
    required this.categoryCode,
    required this.city,
    required this.outsideCity,
    required this.expressway,
    required this.motorway,
    this.notes,
  });

  final String countryCode;
  final String vehicleType;
  final String categoryCode;
  final int city;
  final int outsideCity;
  final int expressway;
  final int motorway;
  final String? notes;

  factory VehicleCategorySpeedLimit.fromJson(Map<String, dynamic> json) {
    return VehicleCategorySpeedLimit(
      countryCode: (json['countryCode'] as String).toUpperCase(),
      vehicleType: json['vehicleType'] as String,
      categoryCode: json['categoryCode'] as String,
      city: json['city'] as int,
      outsideCity: json['outsideCity'] as int,
      expressway: json['expressway'] as int,
      motorway: json['motorway'] as int,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'vehicleType': vehicleType,
      'categoryCode': categoryCode,
      'city': city,
      'outsideCity': outsideCity,
      'expressway': expressway,
      'motorway': motorway,
      if (notes != null) 'notes': notes,
    };
  }
}
