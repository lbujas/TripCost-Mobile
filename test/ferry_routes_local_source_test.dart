import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/data/sources/ferry_routes_local_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads Croatian ferry routes from asset', () async {
    const loader = JsonAssetLoader();
    const source = FerryRoutesLocalSource(loader);

    final routes = await source.getAll();

    expect(routes.length, greaterThanOrEqualTo(30));

    final splitSupetar = routes.firstWhere(
          (route) => route.id == 'hr_631_split_supetar',
    );

    expect(splitSupetar.countryCode, 'HR');
    expect(splitSupetar.fromPortName, 'Split');
    expect(splitSupetar.toPortName, 'Supetar');
    expect(splitSupetar.canCarryVehicles, isTrue);
  });
}