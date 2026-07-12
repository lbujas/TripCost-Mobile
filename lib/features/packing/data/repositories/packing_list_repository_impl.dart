import 'package:travel_cost_planner_europe/features/packing/data/sources/packing_list_local_source.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/repositories/packing_list_repository.dart';

/// Hive-backed implementation of [PackingListRepository].
class PackingListRepositoryImpl implements PackingListRepository {
  PackingListRepositoryImpl(this._localSource);

  final PackingListLocalSource _localSource;

  @override
  Future<List<PackingList>> getPackingLists() {
    return _localSource.getAll(includeDeleted: false);
  }

  @override
  Future<PackingList?> getPackingListById(String id) async {
    final list = await _localSource.getById(id);
    if (list == null || list.deletedAt != null) {
      return null;
    }

    return list;
  }

  @override
  Future<void> savePackingList(PackingList list) async {
    final existing = await _localSource.getById(list.id);
    final now = DateTime.now().toUtc();

    await _localSource.put(
      _copyList(
        list,
        createdAt: existing?.createdAt ?? list.createdAt,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<void> deletePackingListSoft(String id) async {
    final existing = await _requireList(id);
    final now = DateTime.now().toUtc();

    await _localSource.put(_copyList(existing, updatedAt: now, deletedAt: now));
  }

  @override
  Future<void> restorePackingList(String id) async {
    final existing = await _requireList(id);
    final now = DateTime.now().toUtc();

    await _localSource.put(
      _copyList(existing, updatedAt: now, clearDeletedAt: true),
    );
  }

  @override
  Future<void> linkToTrip({
    required String listId,
    required String tripId,
  }) async {
    final existing = await _requireActiveList(listId);
    final now = DateTime.now().toUtc();

    await _localSource.put(
      _copyList(existing, linkedTripId: tripId, updatedAt: now),
    );
  }

  @override
  Future<void> unlinkFromTrip(String listId) async {
    final existing = await _requireActiveList(listId);
    final now = DateTime.now().toUtc();

    await _localSource.put(
      _copyList(existing, clearLinkedTripId: true, updatedAt: now),
    );
  }

  Future<PackingList> _requireList(String id) async {
    final list = await _localSource.getById(id);
    if (list == null) {
      throw StateError('Packing list not found: $id');
    }

    return list;
  }

  Future<PackingList> _requireActiveList(String id) async {
    final list = await _requireList(id);
    if (list.deletedAt != null) {
      throw StateError('Packing list is deleted: $id');
    }

    return list;
  }

  PackingList _copyList(
    PackingList source, {
    String? linkedTripId,
    bool clearLinkedTripId = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return PackingList(
      id: source.id,
      linkedTripId:
          clearLinkedTripId ? null : (linkedTripId ?? source.linkedTripId),
      name: source.name,
      description: source.description,
      departureDate: source.departureDate,
      returnDate: source.returnDate,
      createdAt: createdAt ?? source.createdAt,
      updatedAt: updatedAt ?? source.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? source.deletedAt),
      items: source.items,
      customCategories: source.customCategories,
      persons: source.persons,
      locations: source.locations,
      settings: source.settings,
    );
  }
}
