class CroatiaToll {
  const CroatiaToll({
    required this.id,
    required this.countryCode,
    required this.destination,
    required this.amount,
    required this.currency,
    required this.lastVerified,
  });

  final String id;
  final String countryCode;
  final String destination;
  final double amount;
  final String currency;
  final String lastVerified;

  factory CroatiaToll.fromJson(Map<String, dynamic> json) {
    return CroatiaToll(
      id: json['id'] as String,
      countryCode: json['countryCode'] as String,
      destination: json['destination'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      lastVerified: json['lastVerified'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'countryCode': countryCode,
      'destination': destination,
      'amount': amount,
      'currency': currency,
      'lastVerified': lastVerified,
    };
  }
}
