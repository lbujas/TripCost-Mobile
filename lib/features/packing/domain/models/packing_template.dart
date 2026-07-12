import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template_item.dart';

class PackingTemplate {
  PackingTemplate({
    required this.id,
    this.nameKey,
    this.customName,
    this.descriptionKey,
    this.customDescription,
    this.iconKey,
    this.groupKey,
    this.isSystem = false,
    List<PackingTemplateItem>? items,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  }) : items = List.unmodifiable(items ?? const []);

  final String id;
  final String? nameKey;
  final String? customName;
  final String? descriptionKey;
  final String? customDescription;
  final String? iconKey;
  /// UI grouping for system templates (transport, essentials, trip type, etc.).
  final String? groupKey;
  final bool isSystem;
  final List<PackingTemplateItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  factory PackingTemplate.fromJson(Map<String, dynamic> json) {
    return PackingTemplate(
      id: json['id'] as String,
      nameKey: json['nameKey'] as String?,
      customName: json['customName'] as String?,
      descriptionKey: json['descriptionKey'] as String?,
      customDescription: json['customDescription'] as String?,
      iconKey: json['iconKey'] as String?,
      groupKey: json['groupKey'] as String?,
      isSystem: json['isSystem'] as bool? ?? false,
      items: _parseItems(json['items']),
      createdAt: _parseOptionalDateTime(json['createdAt']),
      updatedAt: _parseOptionalDateTime(json['updatedAt']),
      deletedAt: _parseOptionalDateTime(json['deletedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (nameKey != null) 'nameKey': nameKey,
      if (customName != null) 'customName': customName,
      if (descriptionKey != null) 'descriptionKey': descriptionKey,
      if (customDescription != null) 'customDescription': customDescription,
      if (iconKey != null) 'iconKey': iconKey,
      if (groupKey != null) 'groupKey': groupKey,
      'isSystem': isSystem,
      'items': items.map((item) => item.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
    };
  }
}

List<PackingTemplateItem> _parseItems(Object? raw) {
  if (raw is! List<dynamic>) {
    return const [];
  }

  final items = <PackingTemplateItem>[];
  for (final entry in raw) {
    if (entry is! Map) {
      continue;
    }

    try {
      items.add(PackingTemplateItem.fromJson(Map<String, dynamic>.from(entry)));
    } catch (_) {
      continue;
    }
  }

  return items;
}

DateTime? _parseOptionalDateTime(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }

  return DateTime.tryParse(value);
}
