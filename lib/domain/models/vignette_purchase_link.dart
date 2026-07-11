class VignettePurchaseLink {
  const VignettePurchaseLink({
    required this.countryCode,
    required this.providerName,
    required this.officialPurchaseUrl,
    required this.notesKey,
  });

  final String countryCode;
  final String providerName;
  final String officialPurchaseUrl;
  final String notesKey;

  factory VignettePurchaseLink.fromJson(Map<String, dynamic> json) {
    return VignettePurchaseLink(
      countryCode: json['countryCode'] as String,
      providerName: json['providerName'] as String,
      officialPurchaseUrl: json['officialPurchaseUrl'] as String,
      notesKey: json['notesKey'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'providerName': providerName,
      'officialPurchaseUrl': officialPurchaseUrl,
      'notesKey': notesKey,
    };
  }
}
