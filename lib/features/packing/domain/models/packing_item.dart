import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_priority.dart';

class PackingItem {
  const PackingItem({
    required this.id,
    required this.packingListId,
    required this.name,
    required this.categoryId,
    this.quantity = 1,
    this.unit = 'piece',
    this.personId,
    this.locationId,
    this.priority = PackingPriority.normal,
    this.isPacked = false,
    this.needsPurchase = false,
    this.isPurchased = false,
    this.note,
    this.weightPerUnitGrams,
    this.reminderAt,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String packingListId;
  final String name;
  final String categoryId;
  final int quantity;
  final String unit;
  final String? personId;
  final String? locationId;
  final PackingPriority priority;
  final bool isPacked;
  final bool needsPurchase;
  final bool isPurchased;
  final String? note;
  final double? weightPerUnitGrams;
  final DateTime? reminderAt;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  factory PackingItem.fromJson(Map<String, dynamic> json) {
    return PackingItem(
      id: json['id'] as String,
      packingListId: json['packingListId'] as String,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String,
      quantity: _parseQuantity(json['quantity'], fallback: 1),
      unit: json['unit'] as String? ?? 'piece',
      personId: json['personId'] as String?,
      locationId: json['locationId'] as String?,
      priority: PackingPriority.fromJson(json['priority']),
      isPacked: json['isPacked'] as bool? ?? false,
      needsPurchase: json['needsPurchase'] as bool? ?? false,
      isPurchased: json['isPurchased'] as bool? ?? false,
      note: json['note'] as String?,
      weightPerUnitGrams: _parseOptionalDouble(json['weightPerUnitGrams']),
      reminderAt: _parseOptionalDateTime(json['reminderAt']),
      sortOrder: _parseInt(json['sortOrder'], fallback: 0),
      createdAt: _parseRequiredDateTime(json['createdAt']),
      updatedAt: _parseRequiredDateTime(json['updatedAt']),
      deletedAt: _parseOptionalDateTime(json['deletedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packingListId': packingListId,
      'name': name,
      'categoryId': categoryId,
      'quantity': quantity,
      'unit': unit,
      if (personId != null) 'personId': personId,
      if (locationId != null) 'locationId': locationId,
      'priority': priority.toJson(),
      'isPacked': isPacked,
      'needsPurchase': needsPurchase,
      'isPurchased': isPurchased,
      if (note != null) 'note': note,
      if (weightPerUnitGrams != null) 'weightPerUnitGrams': weightPerUnitGrams,
      if (reminderAt != null) 'reminderAt': reminderAt!.toIso8601String(),
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
    };
  }
}

DateTime _parseRequiredDateTime(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  return DateTime.fromMillisecondsSinceEpoch(0);
}

DateTime? _parseOptionalDateTime(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }

  return DateTime.tryParse(value);
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

double? _parseOptionalDouble(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return null;
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
