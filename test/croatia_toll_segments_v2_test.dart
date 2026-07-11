import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/data/sources/croatia_toll_segments_v2_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_toll_segment_v2.dart';
import 'package:travel_cost_planner_europe/domain/services/croatia_toll_segments_v2_validator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const loader = JsonAssetLoader();
  const source = CroatiaTollSegmentsV2LocalSource(loader);
  const validator = CroatiaTollSegmentsV2Validator();

  group('CroatiaTollSegmentV2', () {
    test('fromJson parses segment fields', () {
      final segment = CroatiaTollSegmentV2.fromJson({
        'id': 'hr_v2_gorican_lucko_cat_i',
        'countryCode': 'HR',
        'fromGateId': 'gorican',
        'fromGateName': 'Goričan',
        'toGateId': 'lucko',
        'toGateName': 'Zagreb/Lučko',
        'categoryCode': 'I',
        'amount': 5.8,
        'currency': 'EUR',
        'accuracy': 'verified',
        'source': 'Autopay calculator screenshot',
        'lastVerified': '2026-06-10',
      });

      expect(segment.countryCode, 'HR');
      expect(segment.isEntrySegment, isTrue);
      expect(segment.isExitSegment, isFalse);
      expect(segment.amount, 5.8);
    });
  });

  group('croatia_toll_segments_v2.json', () {
    test('loads all segment categories from JSON', () async {
      final segments = await source.getAll();

      expect(segments, hasLength(38));
      expect(segments.where((segment) => segment.isEntrySegment), hasLength(7));
      expect(segments.where((segment) => segment.isExitSegment), hasLength(31));
      expect(
        segments.where((segment) => segment.categoryCode == 'I'),
        hasLength(14),
      );
      expect(
        segments.where((segment) => segment.categoryCode == 'IA'),
        hasLength(12),
      );
      expect(
        segments.where((segment) => segment.categoryCode == 'II'),
        hasLength(12),
      );
    });

    test('category I is present for all active app segments', () async {
      final segments = await source.getAll();
      final report = validator.validateCoverage(segments);

      final missingCategoryI = report.missingForCategory('I');
      expect(missingCategoryI, isEmpty);

      final activeSegmentCount =
          CroatiaTollSegmentsV2Validator.activeEntryGateIds.length +
              CroatiaTollSegmentsV2Validator.activeExitGateIds.length;
      final presentCategoryI = report.present
          .where((item) => item.categoryCode == 'I')
          .length;
      expect(presentCategoryI, activeSegmentCount);
    });

    test('active app segments have full IA, I, and II coverage', () async {
      final segments = await source.getAll();
      final report = validator.validateCoverage(segments);

      expect(report.hasFullCoverage, isTrue);
      expect(report.missing, isEmpty);
      expect(report.present, hasLength(36));

      final estimatedSegments = segments.where(
        (segment) =>
            segment.accuracy == 'estimated' &&
            (segment.categoryCode == 'IA' || segment.categoryCode == 'II'),
      );
      expect(estimatedSegments, hasLength(4));
      expect(
        estimatedSegments.map((segment) => segment.id).toSet(),
        {
          'hr_v2_trakoscan_lucko_cat_ia',
          'hr_v2_trakoscan_lucko_cat_ii',
          'hr_v2_lucko_pula_cat_ia',
          'hr_v2_lucko_pula_cat_ii',
        },
      );
    });

    test('getSegment returns gorican to lucko category I', () async {
      final segment = await source.getSegment(
        fromGateId: 'gorican',
        toGateId: 'lucko',
        categoryCode: 'I',
      );

      expect(segment, isNotNull);
      expect(segment!.amount, 6.4);
    });
  });
}
