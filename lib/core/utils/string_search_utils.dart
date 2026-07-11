/// Utilities for user-facing text search.
class StringSearchUtils {
  StringSearchUtils._();

  static const Map<String, String> _diacriticReplacements = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'å': 'a',
    'ą': 'a',
    'ă': 'a',
    'ć': 'c',
    'č': 'c',
    'ç': 'c',
    'ď': 'd',
    'đ': 'd',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ę': 'e',
    'ě': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ł': 'l',
    'ń': 'n',
    'ñ': 'n',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ő': 'o',
    'ř': 'r',
    'ś': 's',
    'ş': 's',
    'š': 's',
    'ß': 'ss',
    'ť': 't',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ů': 'u',
    'ű': 'u',
    'ý': 'y',
    'ź': 'z',
    'ż': 'z',
    'ž': 'z',
  };

  /// Lowercases [input] and strips common European diacritics for matching.
  static String normalizeForSearch(String input) {
    final buffer = StringBuffer();
    for (final char in input.toLowerCase().split('')) {
      buffer.write(_diacriticReplacements[char] ?? char);
    }
    return buffer.toString();
  }

  /// Returns true when [query] matches [text] using diacritic-insensitive search.
  static bool matchesQuery(String text, String query) {
    if (query.isEmpty) {
      return true;
    }
    return normalizeForSearch(text).contains(normalizeForSearch(query));
  }
}
