class CroatiaRegion {
  const CroatiaRegion({
    required this.id,
    required this.nameKey,
    required this.countryCode,
    required this.defaultTollId,
  });

  final String id;
  final String nameKey;
  final String countryCode;
  final String defaultTollId;

  factory CroatiaRegion.fromJson(Map<String, dynamic> json) {
    return CroatiaRegion(
      id: json['id'] as String,
      nameKey: json['nameKey'] as String,
      countryCode: json['countryCode'] as String,
      defaultTollId: json['defaultTollId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameKey': nameKey,
      'countryCode': countryCode,
      'defaultTollId': defaultTollId,
    };
  }
}
