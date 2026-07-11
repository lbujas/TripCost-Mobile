import 'package:travel_cost_planner_europe/domain/models/croatia_toll_matrix_entry.dart';

abstract class CroatiaTollMatrixRepository {
  Future<CroatiaTollMatrixEntry?> getToll({
    required String entryGateId,
    required String exitGateId,
    String vehicleCategory = 'I',
  });
}
