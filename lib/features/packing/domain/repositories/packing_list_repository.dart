import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';

/// Contract for persisting packing lists locally.
abstract class PackingListRepository {
  Future<List<PackingList>> getPackingLists();

  Future<PackingList?> getPackingListById(String id);

  Future<void> savePackingList(PackingList list);

  Future<void> deletePackingListSoft(String id);

  Future<void> restorePackingList(String id);

  Future<void> linkToTrip({required String listId, required String tripId});

  Future<void> unlinkFromTrip(String listId);
}
