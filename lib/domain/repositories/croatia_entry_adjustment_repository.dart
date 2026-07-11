import 'package:travel_cost_planner_europe/domain/models/croatia_entry_adjustment.dart';

abstract class CroatiaEntryAdjustmentRepository {
  Future<CroatiaEntryAdjustment?> getByEntryGateId(String entryGateId);
}
