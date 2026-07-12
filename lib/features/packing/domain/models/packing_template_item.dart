import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_priority.dart';

class PackingTemplateItem {
  const PackingTemplateItem({
    required this.id,
    this.nameKey,
    this.customName,
    this.categoryKey,
    this.customCategoryName,
    this.quantity = 1,
    this.unitKey = 'packingTemplateUnitPiece',
    this.priority = PackingPriority.normal,
    this.needsPurchase = false,
    this.noteKey,
    this.customNote,
    this.sortOrder = 0,
  });

  final String id;
  final String? nameKey;
  final String? customName;
  final String? categoryKey;
  final String? customCategoryName;
  final int quantity;
  final String unitKey;
  final PackingPriority priority;
  final bool needsPurchase;
  final String? noteKey;
  final String? customNote;
  final int sortOrder;

  factory PackingTemplateItem.fromJson(Map<String, dynamic> json) {
    return PackingTemplateItem(
      id: json['id'] as String,
      nameKey: json['nameKey'] as String?,
      customName: json['customName'] as String?,
      categoryKey: json['categoryKey'] as String?,
      customCategoryName: json['customCategoryName'] as String?,
      quantity: _parseQuantity(json['quantity'], fallback: 1),
      unitKey: json['unitKey'] as String? ?? 'packingTemplateUnitPiece',
      priority: PackingPriority.fromJson(json['priority']),
      needsPurchase: json['needsPurchase'] as bool? ?? false,
      noteKey: json['noteKey'] as String?,
      customNote: json['customNote'] as String?,
      sortOrder: _parseInt(json['sortOrder'], fallback: 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (nameKey != null) 'nameKey': nameKey,
      if (customName != null) 'customName': customName,
      if (categoryKey != null) 'categoryKey': categoryKey,
      if (customCategoryName != null) 'customCategoryName': customCategoryName,
      'quantity': quantity,
      'unitKey': unitKey,
      'priority': priority.toJson(),
      'needsPurchase': needsPurchase,
      if (noteKey != null) 'noteKey': noteKey,
      if (customNote != null) 'customNote': customNote,
      'sortOrder': sortOrder,
    };
  }
}

int _parseQuantity(Object? value, {required int fallback}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  return fallback;
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
