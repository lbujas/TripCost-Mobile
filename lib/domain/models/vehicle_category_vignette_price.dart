/// Vignette price row keyed by country and official vehicle category (v2 data).
class VehicleCategoryVignettePrice {
  const VehicleCategoryVignettePrice({
    required this.countryCode,
    required this.categoryCode,
    required this.name,
    required this.validityDays,
    required this.price,
    required this.currency,
    this.notes,
  });

  final String countryCode;
  final String categoryCode;
  final String name;
  final int validityDays;
  final double price;
  final String currency;
  final String? notes;

  factory VehicleCategoryVignettePrice.fromJson(Map<String, dynamic> json) {
    return VehicleCategoryVignettePrice(
      countryCode: (json['countryCode'] as String).toUpperCase(),
      categoryCode: json['categoryCode'] as String,
      name: json['name'] as String,
      validityDays: json['validityDays'] as int,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'categoryCode': categoryCode,
      'name': name,
      'validityDays': validityDays,
      'price': price,
      'currency': currency,
      if (notes != null) 'notes': notes,
    };
  }
}
