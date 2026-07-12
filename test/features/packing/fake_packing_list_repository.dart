import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/repositories/packing_list_repository.dart';

class FakePackingListRepository implements PackingListRepository {
  FakePackingListRepository({List<PackingList>? lists, this.loadError})
    : lists = List<PackingList>.from(lists ?? const []);

  List<PackingList> lists;
  Object? loadError;
  Object? saveError;
  Object? loadByIdError;

  int saveCallCount = 0;
  int deleteSoftCallCount = 0;
  PackingList? lastSaved;

  @override
  Future<void> deletePackingListSoft(String id) async {
    deleteSoftCallCount++;
    final index = lists.indexWhere((list) => list.id == id);
    if (index == -1) {
      return;
    }

    final existing = lists[index];
    final now = DateTime.now().toUtc();
    lists[index] = PackingList(
      id: existing.id,
      linkedTripId: existing.linkedTripId,
      name: existing.name,
      description: existing.description,
      departureDate: existing.departureDate,
      returnDate: existing.returnDate,
      createdAt: existing.createdAt,
      updatedAt: now,
      deletedAt: now,
      items: existing.items,
      customCategories: existing.customCategories,
      persons: existing.persons,
      locations: existing.locations,
      settings: existing.settings,
    );
  }

  @override
  Future<List<PackingList>> getPackingLists() async {
    if (loadError != null) {
      throw loadError!;
    }

    return lists.where((list) => list.deletedAt == null).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<PackingList?> getPackingListById(String id) async {
    if (loadByIdError != null) {
      throw loadByIdError!;
    }

    for (final list in lists) {
      if (list.id == id && list.deletedAt == null) {
        return list;
      }
    }

    return null;
  }

  @override
  Future<void> linkToTrip({
    required String listId,
    required String tripId,
  }) async {}

  @override
  Future<void> restorePackingList(String id) async {}

  @override
  Future<void> savePackingList(PackingList list) async {
    if (saveError != null) {
      throw saveError!;
    }

    saveCallCount++;
    lastSaved = list;

    final index = lists.indexWhere((entry) => entry.id == list.id);
    if (index == -1) {
      lists.add(list);
      return;
    }

    lists[index] = list;
  }

  @override
  Future<void> unlinkFromTrip(String listId) async {}
}
