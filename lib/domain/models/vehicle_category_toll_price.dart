/// Toll price row keyed by country and official vehicle category (v2 data).
class VehicleCategoryTollPrice {
  const VehicleCategoryTollPrice({
    required this.countryCode,
    required this.categoryCode,
    required this.name,
    required this.amount,
    required this.currency,
    this.routeId,
    this.tollId,
    this.notes,
  }) : assert(
          routeId != null || tollId != null,
          'At least one of routeId or tollId must be provided',
        );

  final String countryCode;
  final String categoryCode;
  final String? routeId;
  final String? tollId;
  final String name;
  final double amount;
  final String currency;
  final String? notes;

  factory VehicleCategoryTollPrice.fromJson(Map<String, dynamic> json) {
    final routeId = json['routeId'] as String?;
    final tollId = json['tollId'] as String?;
    if (routeId == null && tollId == null) {
      throw FormatException(
        'VehicleCategoryTollPrice requires routeId or tollId',
      );
    }

    return VehicleCategoryTollPrice(
      countryCode: (json['countryCode'] as String).toUpperCase(),
      categoryCode: json['categoryCode'] as String,
      routeId: routeId,
      tollId: tollId,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'categoryCode': categoryCode,
      if (routeId != null) 'routeId': routeId,
      if (tollId != null) 'tollId': tollId,
      'name': name,
      'amount': amount,
      'currency': currency,
      if (notes != null) 'notes': notes,
    };
  }
}
