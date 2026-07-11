import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/data/sources/ferry_prices_local_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads Croatian ferry price from asset', () async {
    const loader = JsonAssetLoader();
    const source = FerryPricesLocalSource(loader);

    final prices = await source.getAll();

    expect(prices, hasLength(1));
    expect(prices.first.id, 'hr_631_passenger_car_2026');
    expect(prices.first.routeId, 'hr_631_split_supetar');
    expect(prices.first.vehicleTypeCode, 'passengerCar');
    expect(prices.first.passengerAdultPrice, 6.50);
    expect(prices.first.vehiclePrice, 26.10);
    expect(prices.first.currency, 'EUR');
  });

  test('filters ferry prices by route and vehicle type', () async {
    const loader = JsonAssetLoader();
    const source = FerryPricesLocalSource(loader);

    final prices = await source.getForRouteAndVehicleType(
      routeId: 'hr_631_split_supetar',
      vehicleTypeCode: 'passengerCar',
    );

    expect(prices, hasLength(1));
    expect(prices.first.id, 'hr_631_passenger_car_2026');
  });
}