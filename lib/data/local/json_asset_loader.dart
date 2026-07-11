import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads JSON list data from bundled assets.
class JsonAssetLoader {
  const JsonAssetLoader();

  Future<List<dynamic>> loadJsonList(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final decoded = json.decode(jsonString);

    if (decoded is! List<dynamic>) {
      throw FormatException('Expected a JSON array at $path');
    }

    return decoded;
  }

  Future<Map<String, dynamic>> loadJsonMap(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final decoded = json.decode(jsonString);

    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Expected a JSON object at $path');
    }

    return decoded;
  }
}
