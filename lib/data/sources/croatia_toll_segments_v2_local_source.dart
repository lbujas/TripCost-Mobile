import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_toll_segment_v2.dart';

/// Reads Croatia Lučko segment prices from v2 data.
abstract class CroatiaTollSegmentsV2Reader {
  Future<CroatiaTollSegmentV2?> getSegment({
    required String fromGateId,
    required String toGateId,
    required String categoryCode,
  });
}

/// Local data source for bundled Croatia toll segment v2 prices.
class CroatiaTollSegmentsV2LocalSource implements CroatiaTollSegmentsV2Reader {
  const CroatiaTollSegmentsV2LocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<CroatiaTollSegmentV2>> getAll() async {
    final items = await _loader.loadJsonList(AssetPaths.croatiaTollSegmentsV2);
    return items
        .map(
          (item) => CroatiaTollSegmentV2.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<CroatiaTollSegmentV2?> getSegment({
    required String fromGateId,
    required String toGateId,
    required String categoryCode,
  }) async {
    final segments = await getAll();
    final normalizedCategory = categoryCode.toUpperCase();

    for (final segment in segments) {
      if (segment.fromGateId == fromGateId &&
          segment.toGateId == toGateId &&
          segment.categoryCode.toUpperCase() == normalizedCategory) {
        return segment;
      }
    }

    return null;
  }
}
