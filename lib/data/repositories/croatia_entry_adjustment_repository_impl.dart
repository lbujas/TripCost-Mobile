import 'package:travel_cost_planner_europe/data/sources/croatia_entry_adjustment_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_entry_adjustment.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_entry_adjustment_repository.dart';

class CroatiaEntryAdjustmentRepositoryImpl
    implements CroatiaEntryAdjustmentRepository {
  CroatiaEntryAdjustmentRepositoryImpl(this._localSource);

  final CroatiaEntryAdjustmentLocalSource _localSource;

  List<CroatiaEntryAdjustment>? _cache;

  Future<List<CroatiaEntryAdjustment>> _load() async {
    _cache ??= await _localSource.getAllAdjustments();
    return _cache!;
  }

  @override
  Future<CroatiaEntryAdjustment?> getByEntryGateId(String entryGateId) async {
    final adjustments = await _load();
    for (final adjustment in adjustments) {
      if (adjustment.entryGateId == entryGateId) {
        return adjustment;
      }
    }
    return null;
  }
}
