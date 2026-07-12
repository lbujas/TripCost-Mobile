import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_category.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list_settings.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_location.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_person.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_priority.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_sort_mode.dart';

void main() {
  final createdAt = DateTime.utc(2026, 6, 1, 10, 0);
  final updatedAt = DateTime.utc(2026, 6, 2, 12, 30);
  final departureDate = DateTime.utc(2026, 7, 10);
  final returnDate = DateTime.utc(2026, 7, 20);
  final reminderAt = DateTime.utc(2026, 7, 9, 8, 0);
  final deletedAt = DateTime.utc(2026, 8, 1);

  Map<String, dynamic> completeItemJson({
    bool isPacked = false,
    bool needsPurchase = true,
    bool isPurchased = true,
  }) {
    return {
      'id': 'item-1',
      'packingListId': 'list-1',
      'name': 'Sunscreen',
      'categoryId': 'cat-toiletries',
      'quantity': 2,
      'unit': 'bottle',
      'personId': 'person-1',
      'locationId': 'loc-carry-on',
      'priority': 'important',
      'isPacked': isPacked,
      'needsPurchase': needsPurchase,
      'isPurchased': isPurchased,
      'note': 'SPF 50',
      'weightPerUnitGrams': 250,
      'reminderAt': reminderAt.toIso8601String(),
      'sortOrder': 3,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> completeListJson() {
    return {
      'id': 'list-1',
      'linkedTripId': 'trip-42',
      'name': 'Croatia summer',
      'description': 'Family beach trip',
      'departureDate': departureDate.toIso8601String(),
      'returnDate': returnDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt.toIso8601String(),
      'items': [completeItemJson()],
      'customCategories': [
        {
          'id': 'cat-toiletries',
          'name': 'Toiletries',
          'iconKey': 'toiletries',
          'sortOrder': 1,
          'isSystem': false,
          'createdAt': createdAt.toIso8601String(),
          'updatedAt': updatedAt.toIso8601String(),
        },
      ],
      'persons': [
        {
          'id': 'person-1',
          'name': 'Alex',
          'sortOrder': 0,
          'createdAt': createdAt.toIso8601String(),
          'updatedAt': updatedAt.toIso8601String(),
        },
      ],
      'locations': [
        {
          'id': 'loc-carry-on',
          'name': 'Carry-on luggage',
          'iconKey': 'carry_on',
          'sortOrder': 0,
          'isSystem': true,
          'createdAt': createdAt.toIso8601String(),
          'updatedAt': updatedAt.toIso8601String(),
        },
      ],
      'settings': {
        'defaultSortMode': 'category',
        'showPackedItems': false,
        'showProgress': true,
        'remindersEnabled': true,
      },
      'unknownField': 'ignored',
    };
  }

  group('PackingList', () {
    test('parses complete fromJson', () {
      final list = PackingList.fromJson(completeListJson());

      expect(list.id, 'list-1');
      expect(list.linkedTripId, 'trip-42');
      expect(list.name, 'Croatia summer');
      expect(list.description, 'Family beach trip');
      expect(list.departureDate, departureDate);
      expect(list.returnDate, returnDate);
      expect(list.createdAt, createdAt);
      expect(list.updatedAt, updatedAt);
      expect(list.deletedAt, deletedAt);
      expect(list.items, hasLength(1));
      expect(list.customCategories, hasLength(1));
      expect(list.persons, hasLength(1));
      expect(list.locations, hasLength(1));
      expect(list.settings.defaultSortMode, PackingSortMode.category);
      expect(list.settings.showPackedItems, isFalse);
      expect(list.settings.remindersEnabled, isTrue);
    });

    test('round-trips through toJson and fromJson', () {
      final original = PackingList.fromJson(completeListJson());
      final restored = PackingList.fromJson(original.toJson());

      expect(restored.toJson(), original.toJson());
    });

    test('tolerates missing optional fields', () {
      final list = PackingList.fromJson({
        'id': 'list-minimal',
        'name': 'Weekend',
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      });

      expect(list.linkedTripId, isNull);
      expect(list.description, isNull);
      expect(list.departureDate, isNull);
      expect(list.returnDate, isNull);
      expect(list.deletedAt, isNull);
    });

    test('defaults missing collections to empty lists', () {
      final list = PackingList.fromJson({
        'id': 'list-empty',
        'name': 'Empty',
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      });

      expect(list.items, isEmpty);
      expect(list.customCategories, isEmpty);
      expect(list.persons, isEmpty);
      expect(list.locations, isEmpty);
    });

    test('uses safe defaults for missing settings', () {
      final list = PackingList.fromJson({
        'id': 'list-default-settings',
        'name': 'Defaults',
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      });

      expect(list.settings.defaultSortMode, PackingSortMode.custom);
      expect(list.settings.showPackedItems, isTrue);
      expect(list.settings.showProgress, isTrue);
      expect(list.settings.remindersEnabled, isFalse);
    });

    test('returns unmodifiable nested lists', () {
      final list = PackingList.fromJson(completeListJson());

      expect(
        () => list.items.add(
          PackingItem(
            id: 'extra',
            packingListId: 'list-1',
            name: 'Extra',
            categoryId: 'cat',
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('round-trips full nested structure', () {
      final json = completeListJson();
      final list = PackingList.fromJson(json);
      final encoded = list.toJson();

      expect(encoded['items'], isA<List<dynamic>>());
      expect(encoded['customCategories'], isA<List<dynamic>>());
      expect(encoded['persons'], isA<List<dynamic>>());
      expect(encoded['locations'], isA<List<dynamic>>());
      expect(encoded['settings'], isA<Map<String, dynamic>>());

      final restored = PackingList.fromJson(encoded);
      expect(restored.items.first.name, 'Sunscreen');
      expect(restored.customCategories.first.name, 'Toiletries');
      expect(restored.persons.first.name, 'Alex');
      expect(restored.locations.first.name, 'Carry-on luggage');
      expect(restored.settings.defaultSortMode, PackingSortMode.category);
    });
  });

  group('PackingItem', () {
    test('parses complete fromJson', () {
      final item = PackingItem.fromJson(completeItemJson());

      expect(item.id, 'item-1');
      expect(item.packingListId, 'list-1');
      expect(item.name, 'Sunscreen');
      expect(item.categoryId, 'cat-toiletries');
      expect(item.quantity, 2);
      expect(item.unit, 'bottle');
      expect(item.personId, 'person-1');
      expect(item.locationId, 'loc-carry-on');
      expect(item.priority, PackingPriority.important);
      expect(item.note, 'SPF 50');
      expect(item.weightPerUnitGrams, 250);
      expect(item.reminderAt, reminderAt);
      expect(item.sortOrder, 3);
      expect(item.deletedAt, deletedAt);
    });

    test('parses numeric quantity from int and legacy double JSON values', () {
      final fromInt = PackingItem.fromJson({
        ...completeItemJson(),
        'quantity': 4,
      });
      final fromWholeDouble = PackingItem.fromJson({
        ...completeItemJson(),
        'quantity': 2.0,
      });
      final fromFractionalDouble = PackingItem.fromJson({
        ...completeItemJson(),
        'quantity': 4.5,
      });
      final fromWeightInt = PackingItem.fromJson({
        ...completeItemJson(),
        'weightPerUnitGrams': 300,
      });

      expect(fromInt.quantity, 4);
      expect(fromWholeDouble.quantity, 2);
      expect(fromFractionalDouble.quantity, 5);
      expect(fromWeightInt.weightPerUnitGrams, 300);
    });

    test('round-trips integer quantity in toJson', () {
      final item = PackingItem.fromJson(completeItemJson());

      expect(item.toJson()['quantity'], 2);
    });

    test('uses default values when fields are missing', () {
      final item = PackingItem.fromJson({
        'id': 'item-defaults',
        'packingListId': 'list-1',
        'name': 'T-shirt',
        'categoryId': 'cat-clothes',
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      });

      expect(item.quantity, 1);
      expect(item.unit, 'piece');
      expect(item.priority, PackingPriority.normal);
      expect(item.isPacked, isFalse);
      expect(item.needsPurchase, isFalse);
      expect(item.isPurchased, isFalse);
      expect(item.sortOrder, 0);
    });

    test('keeps packed and purchase states independent', () {
      final purchasedNotPacked = PackingItem.fromJson(
        completeItemJson(isPacked: false, isPurchased: true),
      );
      final packedNotPurchased = PackingItem.fromJson(
        completeItemJson(
          isPacked: true,
          needsPurchase: true,
          isPurchased: false,
        ),
      );

      expect(purchasedNotPacked.isPurchased, isTrue);
      expect(purchasedNotPacked.isPacked, isFalse);
      expect(packedNotPurchased.isPacked, isTrue);
      expect(packedNotPurchased.isPurchased, isFalse);
    });

    test(
      'supports nullable person, location, note, reminder and deletedAt',
      () {
        final item = PackingItem.fromJson({
          'id': 'item-nullables',
          'packingListId': 'list-1',
          'name': 'Passport',
          'categoryId': 'cat-docs',
          'createdAt': createdAt.toIso8601String(),
          'updatedAt': updatedAt.toIso8601String(),
        });

        expect(item.personId, isNull);
        expect(item.locationId, isNull);
        expect(item.note, isNull);
        expect(item.reminderAt, isNull);
        expect(item.deletedAt, isNull);
      },
    );

    test('serializes ISO-8601 dates', () {
      final item = PackingItem.fromJson(completeItemJson());
      final json = item.toJson();

      expect(json['createdAt'], createdAt.toIso8601String());
      expect(json['updatedAt'], updatedAt.toIso8601String());
      expect(json['reminderAt'], reminderAt.toIso8601String());
      expect(json['deletedAt'], deletedAt.toIso8601String());
    });
  });

  group('PackingCategory', () {
    test('serializes and deserializes', () {
      final category = PackingCategory.fromJson({
        'id': 'cat-1',
        'name': 'Electronics',
        'iconKey': 'electronics',
        'sortOrder': 2,
        'isSystem': true,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      });

      final restored = PackingCategory.fromJson(category.toJson());
      expect(restored.id, 'cat-1');
      expect(restored.name, 'Electronics');
      expect(restored.iconKey, 'electronics');
      expect(restored.sortOrder, 2);
      expect(restored.isSystem, isTrue);
      expect(restored.createdAt, createdAt);
      expect(restored.updatedAt, updatedAt);
    });
  });

  group('PackingPerson', () {
    test('serializes and deserializes', () {
      final person = PackingPerson.fromJson({
        'id': 'person-1',
        'name': 'Jamie',
        'sortOrder': 1,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      });

      final restored = PackingPerson.fromJson(person.toJson());
      expect(restored.id, 'person-1');
      expect(restored.name, 'Jamie');
      expect(restored.sortOrder, 1);
    });
  });

  group('PackingLocation', () {
    test('serializes and deserializes', () {
      final location = PackingLocation.fromJson({
        'id': 'loc-1',
        'name': 'Backpack',
        'iconKey': 'backpack',
        'sortOrder': 4,
        'isSystem': false,
      });

      final restored = PackingLocation.fromJson(location.toJson());
      expect(restored.id, 'loc-1');
      expect(restored.name, 'Backpack');
      expect(restored.iconKey, 'backpack');
      expect(restored.sortOrder, 4);
      expect(restored.isSystem, isFalse);
    });
  });

  group('PackingListSettings', () {
    test('uses defaults when JSON is null', () {
      const settings = PackingListSettings();
      final parsed = PackingListSettings.fromJson(null);

      expect(parsed.defaultSortMode, settings.defaultSortMode);
      expect(parsed.showPackedItems, settings.showPackedItems);
      expect(parsed.showProgress, settings.showProgress);
      expect(parsed.remindersEnabled, settings.remindersEnabled);
    });

    test('round-trips custom values', () {
      final settings = PackingListSettings.fromJson({
        'defaultSortMode': 'priority',
        'showPackedItems': false,
        'showProgress': false,
        'remindersEnabled': true,
      });

      final restored = PackingListSettings.fromJson(settings.toJson());
      expect(restored.defaultSortMode, PackingSortMode.priority);
      expect(restored.showPackedItems, isFalse);
      expect(restored.showProgress, isFalse);
      expect(restored.remindersEnabled, isTrue);
    });
  });

  group('PackingPriority', () {
    test('falls back to normal for unknown values', () {
      expect(PackingPriority.fromJson('critical'), PackingPriority.critical);
      expect(PackingPriority.fromJson('unknown'), PackingPriority.normal);
      expect(PackingPriority.fromJson(null), PackingPriority.normal);
      expect(PackingPriority.important.toJson(), 'important');
    });
  });

  group('PackingSortMode', () {
    test('falls back to custom for unknown values', () {
      expect(
        PackingSortMode.fromJson('alphabetical'),
        PackingSortMode.alphabetical,
      );
      expect(PackingSortMode.fromJson('unknown'), PackingSortMode.custom);
      expect(PackingSortMode.fromJson(null), PackingSortMode.custom);
      expect(PackingSortMode.unpackedFirst.toJson(), 'unpackedFirst');
    });
  });

  group('ISO-8601 date serialization', () {
    test('PackingList stores dates as ISO-8601 strings', () {
      final list = PackingList.fromJson(completeListJson());
      final json = list.toJson();

      expect(json['departureDate'], departureDate.toIso8601String());
      expect(json['returnDate'], returnDate.toIso8601String());
      expect(json['createdAt'], createdAt.toIso8601String());
      expect(json['updatedAt'], updatedAt.toIso8601String());
      expect(json['deletedAt'], deletedAt.toIso8601String());
    });
  });
}
