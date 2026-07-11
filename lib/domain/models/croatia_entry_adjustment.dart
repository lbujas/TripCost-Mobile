class CroatiaEntryAdjustment {
  const CroatiaEntryAdjustment({
    required this.id,
    required this.entryGateId,
    required this.entryGateName,
    required this.baseGateId,
    required this.baseGateName,
    required this.amount,
    required this.currency,
    required this.accuracy,
    required this.source,
    required this.lastVerified,
  });

  final String id;
  final String entryGateId;
  final String entryGateName;
  final String baseGateId;
  final String baseGateName;
  final double amount;
  final String currency;
  final String accuracy;
  final String source;
  final String lastVerified;

  bool get isVerified => accuracy == 'verified';

  factory CroatiaEntryAdjustment.fromJson(Map<String, dynamic> json) {
    return CroatiaEntryAdjustment(
      id: json['id'] as String,
      entryGateId: json['entryGateId'] as String,
      entryGateName: json['entryGateName'] as String,
      baseGateId: json['baseGateId'] as String,
      baseGateName: json['baseGateName'] as String,
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
      'entryGateId': entryGateId,
      'entryGateName': entryGateName,
      'baseGateId': baseGateId,
      'baseGateName': baseGateName,
      'amount': amount,
      'currency': currency,
      'accuracy': accuracy,
      'source': source,
      'lastVerified': lastVerified,
    };
  }
}
