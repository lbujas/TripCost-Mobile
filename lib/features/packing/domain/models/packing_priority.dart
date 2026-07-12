enum PackingPriority {
  normal,
  important,
  critical;

  String toJson() => name;

  static PackingPriority fromJson(Object? value) {
    if (value is! String) {
      return PackingPriority.normal;
    }

    for (final priority in PackingPriority.values) {
      if (priority.name == value) {
        return priority;
      }
    }

    return PackingPriority.normal;
  }
}
