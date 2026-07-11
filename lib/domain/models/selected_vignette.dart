class SelectedVignette {
  const SelectedVignette({
    required this.countryCode,
    required this.vignetteName,
    required this.validDays,
    required this.quantity,
    required this.unitPrice,
    required this.currency,
    required this.totalPricePln,
  });

  final String countryCode;
  final String vignetteName;
  final int validDays;
  final int quantity;
  final double unitPrice;
  final String currency;
  final double totalPricePln;

  factory SelectedVignette.fromJson(Map<String, dynamic> json) {
    return SelectedVignette(
      countryCode: json['countryCode'] as String,
      vignetteName: json['vignetteName'] as String,
      validDays: json['validDays'] as int,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      currency: json['currency'] as String,
      totalPricePln: (json['totalPricePln'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'vignetteName': vignetteName,
      'validDays': validDays,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'currency': currency,
      'totalPricePln': totalPricePln,
    };
  }
}
