import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const loader = JsonAssetLoader();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final key = const StringCodec().decodeMessage(message);
      if (key == AssetPaths.routes) {
        return const StringCodec().encodeMessage('[]');
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  test('loadJsonList returns decoded JSON array', () async {
    final result = await loader.loadJsonList(AssetPaths.routes);
    expect(result, isEmpty);
  });
}
