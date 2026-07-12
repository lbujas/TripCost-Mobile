import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/packing_list_duplicate_helper.dart';

import '../packing_test_data.dart';

void main() {
  group('duplicatePackingList', () {
    test('creates independent copy with new ids and copied name', () {
      final source = samplePackingList(id: 'list-1', name: 'Croatia 2026');

      final duplicate = duplicatePackingList(
        source,
        copiedName: 'Croatia 2026 (Copy)',
      );

      expect(duplicate.id, isNot(source.id));
      expect(duplicate.name, 'Croatia 2026 (Copy)');
      expect(duplicate.description, source.description);
      expect(duplicate.settings, source.settings);
      expect(duplicate.items, hasLength(source.items.length));
      expect(duplicate.items.first.id, isNot(source.items.first.id));
      expect(duplicate.items.first.packingListId, duplicate.id);
      expect(duplicate.items.first.isPacked, source.items.first.isPacked);
      expect(duplicate.items.first.isPurchased, source.items.first.isPurchased);
      expect(
        duplicate.customCategories.first.id,
        isNot(source.customCategories.first.id),
      );
      expect(duplicate.persons.first.id, isNot(source.persons.first.id));
      expect(duplicate.locations.first.id, isNot(source.locations.first.id));
      expect(duplicate.createdAt, isNot(source.createdAt));
      expect(duplicate.updatedAt, isNot(source.updatedAt));
    });
  });
}
