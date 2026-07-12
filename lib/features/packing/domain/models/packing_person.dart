class PackingPerson {
  const PackingPerson({
    required this.id,
    required this.name,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PackingPerson.fromJson(Map<String, dynamic> json) {
    return PackingPerson(
      id: json['id'] as String,
      name: json['name'] as String,
      sortOrder: _parseInt(json['sortOrder'], fallback: 0),
      createdAt: _parseOptionalDateTime(json['createdAt']),
      updatedAt: _parseOptionalDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sortOrder': sortOrder,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

DateTime? _parseOptionalDateTime(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }

  return DateTime.tryParse(value);
}

int _parseInt(Object? value, {required int fallback}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return fallback;
}
