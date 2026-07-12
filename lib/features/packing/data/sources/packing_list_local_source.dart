import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';

/// Local data source for packing lists stored as individual Hive JSON records.
class PackingListLocalSource {
  PackingListLocalSource(this._hiveService);

  final HiveService _hiveService;

  Future<List<PackingList>> getAll({required bool includeDeleted}) async {
    return _readAll(includeDeleted: includeDeleted);
  }

  Future<PackingList?> getById(String id) async {
    final raw = _hiveService.packingListsBox.get(id);
    return _parseRecord(raw);
  }

  Future<void> put(PackingList list) async {
    await _hiveService.packingListsBox.put(list.id, list.toJson());
  }

  List<PackingList> _readAll({required bool includeDeleted}) {
    final lists = <PackingList>[];

    for (final key in _hiveService.packingListsBox.keys) {
      final raw = _hiveService.packingListsBox.get(key);
      final list = _parseRecord(raw);
      if (list == null) {
        continue;
      }

      if (!includeDeleted && list.deletedAt != null) {
        continue;
      }

      lists.add(list);
    }

    lists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return lists;
  }

  PackingList? _parseRecord(Object? raw) {
    if (raw is! Map) {
      return null;
    }

    try {
      return PackingList.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }
}
