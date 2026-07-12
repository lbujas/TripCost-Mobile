import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_list_helpers.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';

final packingListsControllerProvider =
    AsyncNotifierProvider<PackingListsController, List<PackingList>>(
      PackingListsController.new,
    );

class PackingListsController extends AsyncNotifier<List<PackingList>> {
  @override
  Future<List<PackingList>> build() async {
    return _loadLists();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadLists);
  }

  Future<bool> createPackingList({
    required String name,
    String? description,
  }) async {
    final trimmedName = name.trim();
    final trimmedDescription = description?.trim();

    if (trimmedName.isEmpty) {
      return false;
    }

    final now = DateTime.now().toUtc();
    final list = PackingList(
      id: 'packing_list_${now.microsecondsSinceEpoch}',
      name: trimmedName,
      description:
          trimmedDescription == null || trimmedDescription.isEmpty
              ? null
              : trimmedDescription,
      createdAt: now,
      updatedAt: now,
    );

    await savePackingList(list);
    return true;
  }

  Future<void> savePackingList(PackingList list) async {
    await ref.read(packingListRepositoryProvider).savePackingList(list);
    state = await AsyncValue.guard(_loadLists);
  }

  Future<List<PackingList>> _loadLists() {
    return ref.read(packingListRepositoryProvider).getPackingLists();
  }

  static List<PackingList> sortedByUpdatedAt(List<PackingList> lists) {
    final sorted = [...lists];
    sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }
}

int packingListActiveItemCount(PackingList list) =>
    packingActiveItemCount(list);

int packingListPackedItemCount(PackingList list) =>
    packingPackedActiveItemCount(list);
