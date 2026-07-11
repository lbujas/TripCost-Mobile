import 'package:travel_cost_planner_europe/data/sources/croatia_toll_matrix_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_toll_matrix_entry.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_toll_matrix_repository.dart';

class CroatiaTollMatrixRepositoryImpl implements CroatiaTollMatrixRepository {
  CroatiaTollMatrixRepositoryImpl(this._localSource);

  final CroatiaTollMatrixLocalSource _localSource;

  List<CroatiaTollMatrixEntry>? _cache;

  Future<List<CroatiaTollMatrixEntry>> _loadEntries() async {
    _cache ??= await _localSource.getAllEntries();
    return _cache!;
  }

  @override
  Future<CroatiaTollMatrixEntry?> getToll({
    required String entryGateId,
    required String exitGateId,
    String vehicleCategory = 'I',
  }) async {
    final entries = await _loadEntries();
    final normalizedCategory = vehicleCategory.toUpperCase();

    for (final entry in entries) {
      if (entry.entryGateId == entryGateId &&
          entry.exitGateId == exitGateId &&
          entry.vehicleCategory.toUpperCase() == normalizedCategory) {
        return entry;
      }
    }

    return null;
  }
}
