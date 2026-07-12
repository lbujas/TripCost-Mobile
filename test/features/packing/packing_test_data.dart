import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_category.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list_settings.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_location.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_person.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_priority.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_sort_mode.dart';

PackingList samplePackingList({
  String id = 'list-1',
  String? linkedTripId,
  String name = 'Croatia summer',
  String? description = 'Family beach trip',
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? deletedAt,
}) {
  final created = createdAt ?? DateTime.utc(2026, 6, 1, 10, 0);
  final updated = updatedAt ?? DateTime.utc(2026, 6, 2, 12, 30);

  return PackingList(
    id: id,
    linkedTripId: linkedTripId,
    name: name,
    description: description,
    departureDate: DateTime.utc(2026, 7, 10),
    returnDate: DateTime.utc(2026, 7, 20),
    createdAt: created,
    updatedAt: updated,
    deletedAt: deletedAt,
    items: [
      PackingItem(
        id: 'item-1',
        packingListId: id,
        name: 'Sunscreen',
        categoryId: 'cat-toiletries',
        quantity: 2,
        unit: 'bottle',
        personId: 'person-1',
        locationId: 'loc-carry-on',
        priority: PackingPriority.important,
        needsPurchase: true,
        isPurchased: true,
        note: 'SPF 50',
        weightPerUnitGrams: 250,
        reminderAt: DateTime.utc(2026, 7, 9, 8, 0),
        sortOrder: 3,
        createdAt: created,
        updatedAt: updated,
      ),
    ],
    customCategories: [
      PackingCategory(
        id: 'cat-toiletries',
        name: 'Toiletries',
        iconKey: 'toiletries',
        sortOrder: 1,
        createdAt: created,
        updatedAt: updated,
      ),
    ],
    persons: [
      PackingPerson(
        id: 'person-1',
        name: 'Alex',
        sortOrder: 0,
        createdAt: created,
        updatedAt: updated,
      ),
    ],
    locations: [
      PackingLocation(
        id: 'loc-carry-on',
        name: 'Carry-on luggage',
        iconKey: 'carry_on',
        sortOrder: 0,
        isSystem: true,
        createdAt: created,
        updatedAt: updated,
      ),
    ],
    settings: const PackingListSettings(
      defaultSortMode: PackingSortMode.category,
      showPackedItems: false,
      showProgress: true,
      remindersEnabled: true,
    ),
  );
}
