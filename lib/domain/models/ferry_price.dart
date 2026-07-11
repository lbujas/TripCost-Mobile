class FerryPrice {
  const FerryPrice({
    required this.id,
    required this.routeId,
    required this.vehicleTypeCode,
    required this.passengerAdultPrice,
    required this.vehiclePrice,
    this.trailerPrice,
    required this.currency,
    required this.season,
    this.validFrom,
    this.validTo,
    this.sourceUrl,
    this.lastVerified,
    this.notes,
  });

  final String id;
  final String routeId;
  final String vehicleTypeCode;
  final double passengerAdultPrice;
  final double vehiclePrice;
  final double? trailerPrice;
  final String currency;
  final String season;
  final String? validFrom;
  final String? validTo;
  final String? sourceUrl;
  final String? lastVerified;
  final String? notes;

  factory FerryPrice.fromJson(Map<String, dynamic> json) {
    return FerryPrice(
      id: json['id'] as String,
      routeId: json['routeId'] as String,
      vehicleTypeCode: json['vehicleTypeCode'] as String,
      passengerAdultPrice: (json['passengerAdultPrice'] as num).toDouble(),
      vehiclePrice: (json['vehiclePrice'] as num).toDouble(),
      trailerPrice: (json['trailerPrice'] as num?)?.toDouble(),
      currency: json['currency'] as String,
      season: json['season'] as String,
      validFrom: json['validFrom'] as String?,
      validTo: json['validTo'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      lastVerified: json['lastVerified'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'vehicleTypeCode': vehicleTypeCode,
      'passengerAdultPrice': passengerAdultPrice,
      'vehiclePrice': vehiclePrice,
      if (trailerPrice != null) 'trailerPrice': trailerPrice,
      'currency': currency,
      'season': season,
      if (validFrom != null) 'validFrom': validFrom,
      if (validTo != null) 'validTo': validTo,
      if (sourceUrl != null) 'sourceUrl': sourceUrl,
      if (lastVerified != null) 'lastVerified': lastVerified,
      if (notes != null) 'notes': notes,
    };
  }
}