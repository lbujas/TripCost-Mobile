class Vignette {
  const Vignette({
    required this.countryCode,
    required this.name,
    required this.price,
    required this.currency,
    required this.validityDays,
  });

  final String countryCode;
  final String name;
  final double price;
  final String currency;
  final int validityDays;

  factory Vignette.fromJson(Map<String, dynamic> json) {
    return Vignette(
      countryCode: json['countryCode'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      validityDays: json['validityDays'] as int,
    );
  }
}
