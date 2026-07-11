class FuelPricesSnapshot {
  const FuelPricesSnapshot({
    required this.pricesByCountry,
    this.source,
    this.updatedAt,
  });

  final String? source;
  final String? updatedAt;
  final Map<String, Map<String, double?>> pricesByCountry;

  factory FuelPricesSnapshot.empty() {
    return const FuelPricesSnapshot(pricesByCountry: {});
  }

  factory FuelPricesSnapshot.fromJson(Map<String, dynamic> json) {
    final pricesRaw = json['prices'];
    final pricesByCountry = <String, Map<String, double?>>{};

    if (pricesRaw is Map<String, dynamic>) {
      for (final entry in pricesRaw.entries) {
        if (entry.value is! Map<String, dynamic>) {
          continue;
        }

        final countryPrices = entry.value as Map<String, dynamic>;
        pricesByCountry[entry.key.toUpperCase()] = {
          'petrol95': _readPrice(countryPrices['petrol95']),
          'diesel': _readPrice(countryPrices['diesel']),
          'lpg': _readPrice(countryPrices['lpg']),
        };
      }
    }

    return FuelPricesSnapshot(
      source: json['source'] as String?,
      updatedAt: json['updatedAt'] as String?,
      pricesByCountry: pricesByCountry,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (source != null) 'source': source,
      if (updatedAt != null) 'updatedAt': updatedAt,
      'prices': pricesByCountry.map(
        (countryCode, prices) => MapEntry(countryCode, prices),
      ),
    };
  }

  double? priceForCountry({
    required String countryCode,
    required String backendField,
  }) {
    return pricesByCountry[countryCode.toUpperCase()]?[backendField];
  }

  static double? _readPrice(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }
}
