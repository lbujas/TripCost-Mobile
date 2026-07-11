class SelectedFerry {
  const SelectedFerry({
    required this.routeId,
    required this.routeName,
    required this.fromPortName,
    required this.toPortName,
    required this.operatorName,
    required this.vehicleTypeCode,
    required this.peopleCount,
    required this.passengerAdultPrice,
    required this.vehiclePrice,
    this.trailerPrice,
    required this.currency,
    required this.oneWayTotalOriginalCurrency,
    required this.totalOriginalCurrency,
    required this.totalPricePln,
    required this.crossings,
    this.purchaseUrl,
    this.sourceUrl,
    this.notes,
  });

  final String routeId;
  final String routeName;
  final String fromPortName;
  final String toPortName;
  final String operatorName;
  final String vehicleTypeCode;
  final int peopleCount;
  final double passengerAdultPrice;
  final double vehiclePrice;
  final double? trailerPrice;
  final String currency;
  final double oneWayTotalOriginalCurrency;
  final double totalOriginalCurrency;
  final double totalPricePln;
  final int crossings;
  final String? purchaseUrl;
  final String? sourceUrl;
  final String? notes;

  factory SelectedFerry.fromJson(Map<String, dynamic> json) {
    return SelectedFerry(
      routeId: json['routeId'] as String,
      routeName: json['routeName'] as String,
      fromPortName: json['fromPortName'] as String,
      toPortName: json['toPortName'] as String,
      operatorName: json['operatorName'] as String,
      vehicleTypeCode: json['vehicleTypeCode'] as String,
      peopleCount: json['peopleCount'] as int,
      passengerAdultPrice: (json['passengerAdultPrice'] as num).toDouble(),
      vehiclePrice: (json['vehiclePrice'] as num).toDouble(),
      trailerPrice: (json['trailerPrice'] as num?)?.toDouble(),
      currency: json['currency'] as String,
      oneWayTotalOriginalCurrency:
      (json['oneWayTotalOriginalCurrency'] as num).toDouble(),
      totalOriginalCurrency: (json['totalOriginalCurrency'] as num).toDouble(),
      totalPricePln: (json['totalPricePln'] as num).toDouble(),
      crossings: json['crossings'] as int,
      purchaseUrl: json['purchaseUrl'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'routeName': routeName,
      'fromPortName': fromPortName,
      'toPortName': toPortName,
      'operatorName': operatorName,
      'vehicleTypeCode': vehicleTypeCode,
      'peopleCount': peopleCount,
      'passengerAdultPrice': passengerAdultPrice,
      'vehiclePrice': vehiclePrice,
      if (trailerPrice != null) 'trailerPrice': trailerPrice,
      'currency': currency,
      'oneWayTotalOriginalCurrency': oneWayTotalOriginalCurrency,
      'totalOriginalCurrency': totalOriginalCurrency,
      'totalPricePln': totalPricePln,
      'crossings': crossings,
      if (purchaseUrl != null) 'purchaseUrl': purchaseUrl,
      if (sourceUrl != null) 'sourceUrl': sourceUrl,
      if (notes != null) 'notes': notes,
    };
  }
}