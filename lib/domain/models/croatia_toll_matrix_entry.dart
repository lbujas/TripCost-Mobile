class CroatiaTollMatrixEntry {
  const CroatiaTollMatrixEntry({
    required this.id,
    required this.entryGateId,
    required this.exitGateId,
    required this.vehicleCategory,
    required this.amount,
    required this.currency,
    required this.lastVerified,
    required this.accuracy,
  });

  final String id;
  final String entryGateId;
  final String exitGateId;
  final String vehicleCategory;
  final double amount;
  final String currency;
  final String lastVerified;
  final String accuracy;

  bool get isEstimated => accuracy == 'estimated';

  factory CroatiaTollMatrixEntry.fromJson(Map<String, dynamic> json) {
    return CroatiaTollMatrixEntry(
      id: json['id'] as String,
      entryGateId: json['entryGateId'] as String,
      exitGateId: json['exitGateId'] as String,
      vehicleCategory: json['vehicleCategory'] as String? ?? 'I',
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      lastVerified: json['lastVerified'] as String,
      accuracy: json['accuracy'] as String? ?? 'estimated',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entryGateId': entryGateId,
      'exitGateId': exitGateId,
      'vehicleCategory': vehicleCategory,
      'amount': amount,
      'currency': currency,
      'lastVerified': lastVerified,
      'accuracy': accuracy,
    };
  }
}
