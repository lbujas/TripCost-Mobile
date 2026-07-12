import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_category.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_location.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_person.dart';

/// Builds an independent copy of [source] with new entity IDs and timestamps.
PackingList duplicatePackingList(
  PackingList source, {
  required String copiedName,
}) {
  final now = DateTime.now().toUtc();
  var counter = 0;

  String newId(String prefix) {
    counter += 1;
    return '${prefix}_${now.microsecondsSinceEpoch}_$counter';
  }

  final newListId = newId('packing_list');
  final categoryIdMap = <String, String>{};
  final categories =
      source.customCategories.map((category) {
        final id = newId('packing_cat');
        categoryIdMap[category.id] = id;
        return PackingCategory(
          id: id,
          name: category.name,
          iconKey: category.iconKey,
          sortOrder: category.sortOrder,
          isSystem: category.isSystem,
          createdAt: now,
          updatedAt: now,
        );
      }).toList();

  final personIdMap = <String, String>{};
  final persons =
      source.persons.map((person) {
        final id = newId('packing_person');
        personIdMap[person.id] = id;
        return PackingPerson(
          id: id,
          name: person.name,
          sortOrder: person.sortOrder,
          createdAt: now,
          updatedAt: now,
        );
      }).toList();

  final locationIdMap = <String, String>{};
  final locations =
      source.locations.map((location) {
        final id = newId('packing_loc');
        locationIdMap[location.id] = id;
        return PackingLocation(
          id: id,
          name: location.name,
          iconKey: location.iconKey,
          sortOrder: location.sortOrder,
          isSystem: location.isSystem,
          createdAt: now,
          updatedAt: now,
        );
      }).toList();

  final items =
      source.items.map((item) {
        return PackingItem(
          id: newId('packing_item'),
          packingListId: newListId,
          name: item.name,
          categoryId: categoryIdMap[item.categoryId] ?? item.categoryId,
          quantity: item.quantity,
          unit: item.unit,
          personId:
              item.personId == null
                  ? null
                  : personIdMap[item.personId!] ?? item.personId,
          locationId:
              item.locationId == null
                  ? null
                  : locationIdMap[item.locationId!] ?? item.locationId,
          priority: item.priority,
          isPacked: item.isPacked,
          needsPurchase: item.needsPurchase,
          isPurchased: item.isPurchased,
          note: item.note,
          weightPerUnitGrams: item.weightPerUnitGrams,
          reminderAt: item.reminderAt,
          sortOrder: item.sortOrder,
          createdAt: now,
          updatedAt: now,
          deletedAt: item.deletedAt,
        );
      }).toList();

  return PackingList(
    id: newListId,
    linkedTripId: source.linkedTripId,
    name: copiedName,
    description: source.description,
    departureDate: source.departureDate,
    returnDate: source.returnDate,
    createdAt: now,
    updatedAt: now,
    items: items,
    customCategories: categories,
    persons: persons,
    locations: locations,
    settings: source.settings,
  );
}
