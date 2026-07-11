import 'package:travel_cost_planner_europe/domain/models/polish_start_city.dart';

class PolishVoivodeship {
  const PolishVoivodeship({
    required this.code,
    required this.names,
    required this.cities,
  });

  final String code;
  final Map<String, String> names;
  final List<PolishStartCity> cities;

  String localizedName(String languageCode) {
    return names[languageCode] ??
        names['en'] ??
        names['pl'] ??
        code;
  }

  factory PolishVoivodeship.fromJson(Map<String, dynamic> json) {
    final namesRaw = json['name'] as Map<String, dynamic>;
    final citiesRaw = json['cities'] as List<dynamic>;

    return PolishVoivodeship(
      code: json['code'] as String,
      names: namesRaw.map(
        (key, value) => MapEntry(key, value as String),
      ),
      cities: citiesRaw
          .map(
            (item) => PolishStartCity.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}

class PolishStartCitiesByVoivodeship {
  const PolishStartCitiesByVoivodeship({required this.voivodeships});

  final List<PolishVoivodeship> voivodeships;

  factory PolishStartCitiesByVoivodeship.fromJson(Map<String, dynamic> json) {
    final raw = json['voivodeships'] as List<dynamic>;
    return PolishStartCitiesByVoivodeship(
      voivodeships: raw
          .map(
            (item) => PolishVoivodeship.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}
