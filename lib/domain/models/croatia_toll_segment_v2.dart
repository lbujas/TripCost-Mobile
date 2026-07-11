/// HAC toll price for one Lučko-model segment and vehicle category (v2 data).
class CroatiaTollSegmentV2 {
  const CroatiaTollSegmentV2({
    required this.id,
    required this.countryCode,
    required this.fromGateId,
    required this.fromGateName,
    required this.toGateId,
    required this.toGateName,
    required this.categoryCode,
    required this.amount,
    required this.currency,
    required this.accuracy,
    required this.source,
    required this.lastVerified,
    this.notes,
  });

  final String id;
  final String countryCode;
  final String fromGateId;
  final String fromGateName;
  final String toGateId;
  final String toGateName;
  final String categoryCode;
  final double amount;
  final String currency;
  final String accuracy;
  final String source;
  final String lastVerified;
  final String? notes;

  bool get isEntrySegment => toGateId == 'lucko';

  bool get isExitSegment => fromGateId == 'lucko';

  bool get isMissingPrice => accuracy == 'missing';

  factory CroatiaTollSegmentV2.fromJson(Map<String, dynamic> json) {
    return CroatiaTollSegmentV2(
      id: json['id'] as String,
      countryCode: (json['countryCode'] as String).toUpperCase(),
      fromGateId: json['fromGateId'] as String,
      fromGateName: json['fromGateName'] as String,
      toGateId: json['toGateId'] as String,
      toGateName: json['toGateName'] as String,
      categoryCode: json['categoryCode'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      accuracy: json['accuracy'] as String,
      source: json['source'] as String,
      lastVerified: json['lastVerified'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'countryCode': countryCode,
      'fromGateId': fromGateId,
      'fromGateName': fromGateName,
      'toGateId': toGateId,
      'toGateName': toGateName,
      'categoryCode': categoryCode,
      'amount': amount,
      'currency': currency,
      'accuracy': accuracy,
      'source': source,
      'lastVerified': lastVerified,
      if (notes != null) 'notes': notes,
    };
  }
}
