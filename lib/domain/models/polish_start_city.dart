class PolishStartCity {
  const PolishStartCity({
    required this.id,
    required this.names,
  });

  final String id;
  final Map<String, String> names;

  String localizedName(String languageCode) {
    return names[languageCode] ??
        names['en'] ??
        names['pl'] ??
        id;
  }

  factory PolishStartCity.fromJson(Map<String, dynamic> json) {
    final namesRaw = json['name'] as Map<String, dynamic>;
    return PolishStartCity(
      id: json['id'] as String,
      names: namesRaw.map(
        (key, value) => MapEntry(key, value as String),
      ),
    );
  }
}
