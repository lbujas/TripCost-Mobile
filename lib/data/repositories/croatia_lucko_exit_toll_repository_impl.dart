import 'package:travel_cost_planner_europe/data/sources/croatia_lucko_exit_toll_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_lucko_exit_toll.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_lucko_exit_toll_repository.dart';

class CroatiaLuckoExitTollRepositoryImpl implements CroatiaLuckoExitTollRepository {
  CroatiaLuckoExitTollRepositoryImpl(this._localSource);

  final CroatiaLuckoExitTollLocalSource _localSource;

  List<CroatiaLuckoExitToll>? _cache;

  Future<List<CroatiaLuckoExitToll>> _load() async {
    _cache ??= await _localSource.getAllExitTolls();
    return _cache!;
  }

  @override
  Future<CroatiaLuckoExitToll?> getByExitGateId(String exitGateId) async {
    final exitTolls = await _load();
    for (final exitToll in exitTolls) {
      if (exitToll.exitGateId == exitGateId) {
        return exitToll;
      }
    }
    return null;
  }
}
