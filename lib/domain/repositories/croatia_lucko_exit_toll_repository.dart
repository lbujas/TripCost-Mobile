import 'package:travel_cost_planner_europe/domain/models/croatia_lucko_exit_toll.dart';

abstract class CroatiaLuckoExitTollRepository {
  Future<CroatiaLuckoExitToll?> getByExitGateId(String exitGateId);
}
