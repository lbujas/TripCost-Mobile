class OriginCity {
  const OriginCity({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.popular,
    required this.defaultRouteCountryChains,
  });

  final String id;
  final String name;
  final String countryCode;
  final bool popular;
  final List<List<String>> defaultRouteCountryChains;

  factory OriginCity.fromJson(Map<String, dynamic> json) {
    return OriginCity(
      id: json['id'] as String,
      name: json['name'] as String,
      countryCode: json['countryCode'] as String,
      popular: json['popular'] as bool? ?? false,
      defaultRouteCountryChains:
          (json['defaultRouteCountryChains'] as List<dynamic>)
              .map(
                (chain) => (chain as List<dynamic>)
                    .map((code) => code as String)
                    .toList(),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'countryCode': countryCode,
      'popular': popular,
      'defaultRouteCountryChains': defaultRouteCountryChains,
    };
  }
}
