/// Fuel price for a country and fuel type.
class FuelPrice {
  const FuelPrice({
    required this.countryCode,
    required this.fuelType,
    required this.pricePerLiter,
    required this.currency,
    required this.updatedAt,
  });

  final String countryCode;
  final String fuelType;
  final double pricePerLiter;
  final String currency;
  final DateTime updatedAt;

  factory FuelPrice.fromJson(Map<String, dynamic> json) {
    return FuelPrice(
      countryCode: json['countryCode'] as String,
      fuelType: json['fuelType'] as String,
      pricePerLiter: (json['pricePerLiter'] as num).toDouble(),
      currency: json['currency'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'fuelType': fuelType,
      'pricePerLiter': pricePerLiter,
      'currency': currency,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
