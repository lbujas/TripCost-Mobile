import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_category.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list_settings.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_location.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_person.dart';

class PackingList {
  PackingList({
    required this.id,
    this.linkedTripId,
    required this.name,
    this.description,
    this.departureDate,
    this.returnDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    List<PackingItem>? items,
    List<PackingCategory>? customCategories,
    List<PackingPerson>? persons,
    List<PackingLocation>? locations,
    PackingListSettings? settings,
  }) : items = List.unmodifiable(items ?? const []),
       customCategories = List.unmodifiable(customCategories ?? const []),
       persons = List.unmodifiable(persons ?? const []),
       locations = List.unmodifiable(locations ?? const []),
       settings = settings ?? const PackingListSettings();

  final String id;
  final String? linkedTripId;
  final String name;
  final String? description;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<PackingItem> items;
  final List<PackingCategory> customCategories;
  final List<PackingPerson> persons;
  final List<PackingLocation> locations;
  final PackingListSettings settings;

  factory PackingList.fromJson(Map<String, dynamic> json) {
    return PackingList(
      id: json['id'] as String,
      linkedTripId: json['linkedTripId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      departureDate: _parseOptionalDateTime(json['departureDate']),
      returnDate: _parseOptionalDateTime(json['returnDate']),
      createdAt: _parseRequiredDateTime(json['createdAt']),
      updatedAt: _parseRequiredDateTime(json['updatedAt']),
      deletedAt: _parseOptionalDateTime(json['deletedAt']),
      items: _parseItems(json['items']),
      customCategories: _parseCategories(json['customCategories']),
      persons: _parsePersons(json['persons']),
      locations: _parseLocations(json['locations']),
      settings: PackingListSettings.fromJson(
        json['settings'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (linkedTripId != null) 'linkedTripId': linkedTripId,
      'name': name,
      if (description != null) 'description': description,
      if (departureDate != null)
        'departureDate': departureDate!.toIso8601String(),
      if (returnDate != null) 'returnDate': returnDate!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'customCategories':
          customCategories.map((category) => category.toJson()).toList(),
      'persons': persons.map((person) => person.toJson()).toList(),
      'locations': locations.map((location) => location.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }
}

List<PackingItem> _parseItems(Object? raw) {
  if (raw is! List<dynamic>) {
    return const [];
  }

  final items = <PackingItem>[];
  for (final entry in raw) {
    if (entry is! Map) {
      continue;
    }

    try {
      items.add(PackingItem.fromJson(Map<String, dynamic>.from(entry)));
    } catch (_) {
      continue;
    }
  }

  return items;
}

List<PackingCategory> _parseCategories(Object? raw) {
  if (raw is! List<dynamic>) {
    return const [];
  }

  final categories = <PackingCategory>[];
  for (final entry in raw) {
    if (entry is! Map) {
      continue;
    }

    try {
      categories.add(
        PackingCategory.fromJson(Map<String, dynamic>.from(entry)),
      );
    } catch (_) {
      continue;
    }
  }

  return categories;
}

List<PackingPerson> _parsePersons(Object? raw) {
  if (raw is! List<dynamic>) {
    return const [];
  }

  final persons = <PackingPerson>[];
  for (final entry in raw) {
    if (entry is! Map) {
      continue;
    }

    try {
      persons.add(PackingPerson.fromJson(Map<String, dynamic>.from(entry)));
    } catch (_) {
      continue;
    }
  }

  return persons;
}

List<PackingLocation> _parseLocations(Object? raw) {
  if (raw is! List<dynamic>) {
    return const [];
  }

  final locations = <PackingLocation>[];
  for (final entry in raw) {
    if (entry is! Map) {
      continue;
    }

    try {
      locations.add(PackingLocation.fromJson(Map<String, dynamic>.from(entry)));
    } catch (_) {
      continue;
    }
  }

  return locations;
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
