class CroatiaLuckoExitToll {
  const CroatiaLuckoExitToll({
    required this.id,
    required this.exitGateId,
    required this.exitGateName,
    required this.destinationLabel,
    required this.amount,
    required this.currency,
    required this.accuracy,
    required this.source,
    required this.lastVerified,
  });

  final String id;
  final String exitGateId;
  final String exitGateName;
  final String destinationLabel;
  final double amount;
  final String currency;
  final String accuracy;
  final String source;
  final String lastVerified;

  bool get isVerified => accuracy == 'verified';

  factory CroatiaLuckoExitToll.fromJson(Map<String, dynamic> json) {
    return CroatiaLuckoExitToll(
      id: json['id'] as String,
      exitGateId: json['exitGateId'] as String,
      exitGateName: json['exitGateName'] as String,
      destinationLabel: json['destinationLabel'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      accuracy: json['accuracy'] as String? ?? 'estimated',
      source: json['source'] as String,
      lastVerified: json['lastVerified'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exitGateId': exitGateId,
      'exitGateName': exitGateName,
      'destinationLabel': destinationLabel,
      'amount': amount,
      'currency': currency,
      'accuracy': accuracy,
      'source': source,
      'lastVerified': lastVerified,
    };
  }
}
