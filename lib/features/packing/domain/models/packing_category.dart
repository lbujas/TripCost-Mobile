class PackingCategory {
  const PackingCategory({
    required this.id,
    required this.name,
    this.iconKey,
    this.sortOrder = 0,
    this.isSystem = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? iconKey;
  final int sortOrder;
  final bool isSystem;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PackingCategory.fromJson(Map<String, dynamic> json) {
    return PackingCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      iconKey: json['iconKey'] as String?,
      sortOrder: _parseInt(json['sortOrder'], fallback: 0),
      isSystem: json['isSystem'] as bool? ?? false,
      createdAt: _parseOptionalDateTime(json['createdAt']),
      updatedAt: _parseOptionalDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (iconKey != null) 'iconKey': iconKey,
      'sortOrder': sortOrder,
      'isSystem': isSystem,
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
