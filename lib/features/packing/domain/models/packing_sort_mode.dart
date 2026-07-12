enum PackingSortMode {
  custom,
  alphabetical,
  category,
  person,
  location,
  priority,
  unpackedFirst,
  purchaseRequiredFirst;

  String toJson() => name;

  static PackingSortMode fromJson(Object? value) {
    if (value is! String) {
      return PackingSortMode.custom;
    }

    for (final mode in PackingSortMode.values) {
      if (mode.name == value) {
        return mode;
      }
    }

    return PackingSortMode.custom;
  }
}
