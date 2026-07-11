class Toll {
  const Toll({
    required this.id,
    required this.routeId,
    required this.countryCode,
    required this.name,
    required this.amount,
    required this.currency,
  });

  final String id;
  final String routeId;
  final String countryCode;
  final String name;
  final double amount;
  final String currency;

  factory Toll.fromJson(Map<String, dynamic> json) {
    return Toll(
      id: json['id'] as String,
      routeId: json['routeId'] as String,
      countryCode: json['countryCode'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'countryCode': countryCode,
      'name': name,
      'amount': amount,
      'currency': currency,
    };
  }
}
