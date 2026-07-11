import 'package:travel_cost_planner_europe/domain/models/croatia_toll_segment_v2.dart';

/// Describes one required HAC category price for a Croatia toll segment.
class CroatiaTollSegmentRequirement {
  const CroatiaTollSegmentRequirement({
    required this.segmentKind,
    required this.fromGateId,
    required this.toGateId,
    required this.categoryCode,
  });

  final String segmentKind;
  final String fromGateId;
  final String toGateId;
  final String categoryCode;

  String get segmentKey => '$fromGateId->$toGateId';

  @override
  String toString() =>
      '$segmentKind $segmentKey category $categoryCode';
}

/// Coverage report for active Croatia toll segments and HAC categories.
class CroatiaTollSegmentsV2CoverageReport {
  const CroatiaTollSegmentsV2CoverageReport({
    required this.present,
    required this.missing,
  });

  final List<CroatiaTollSegmentRequirement> present;
  final List<CroatiaTollSegmentRequirement> missing;

  bool get hasFullCoverage => missing.isEmpty;

  List<CroatiaTollSegmentRequirement> missingForCategory(String categoryCode) {
    return missing
        .where((item) => item.categoryCode == categoryCode)
        .toList(growable: false);
  }
}

/// Validates coverage of HAC IA/I/II prices for active Croatia toll segments.
class CroatiaTollSegmentsV2Validator {
  const CroatiaTollSegmentsV2Validator();

  static const List<String> requiredCategories = ['IA', 'I', 'II'];

  static const List<String> activeEntryGateIds = ['gorican', 'trakoscan'];

  static const List<String> activeExitGateIds = [
    'rijeka',
    'pula',
    'zadar',
    'zadar_istok',
    'sibenik',
    'vucevica',
    'dugopolje',
    'sestanovac',
    'ravca',
    'ploce',
  ];

  static const String hubGateId = 'lucko';

  CroatiaTollSegmentsV2CoverageReport validateCoverage(
    List<CroatiaTollSegmentV2> segments,
  ) {
    final indexed = <String, CroatiaTollSegmentV2>{};
    for (final segment in segments) {
      indexed[_key(
        fromGateId: segment.fromGateId,
        toGateId: segment.toGateId,
        categoryCode: segment.categoryCode,
      )] = segment;
    }

    final present = <CroatiaTollSegmentRequirement>[];
    final missing = <CroatiaTollSegmentRequirement>[];

    void checkRequirement(CroatiaTollSegmentRequirement requirement) {
      final segment = indexed[_key(
        fromGateId: requirement.fromGateId,
        toGateId: requirement.toGateId,
        categoryCode: requirement.categoryCode,
      )];

      if (segment != null && !segment.isMissingPrice) {
        present.add(requirement);
        return;
      }

      missing.add(requirement);
    }

    for (final entryGateId in activeEntryGateIds) {
      for (final categoryCode in requiredCategories) {
        checkRequirement(
          CroatiaTollSegmentRequirement(
            segmentKind: 'entry',
            fromGateId: entryGateId,
            toGateId: hubGateId,
            categoryCode: categoryCode,
          ),
        );
      }
    }

    for (final exitGateId in activeExitGateIds) {
      for (final categoryCode in requiredCategories) {
        checkRequirement(
          CroatiaTollSegmentRequirement(
            segmentKind: 'exit',
            fromGateId: hubGateId,
            toGateId: exitGateId,
            categoryCode: categoryCode,
          ),
        );
      }
    }

    return CroatiaTollSegmentsV2CoverageReport(
      present: present,
      missing: missing,
    );
  }

  static String _key({
    required String fromGateId,
    required String toGateId,
    required String categoryCode,
  }) {
    return '$fromGateId|$toGateId|${categoryCode.toUpperCase()}';
  }
}
