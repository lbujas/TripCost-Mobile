import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/packing_template_grouping.dart';

import '../packing_template_test_data.dart';

void main() {
  group('PackingTemplateGrouping', () {
    test('orders known system groups in required sequence', () {
      final templates = [
        sampleSystemTemplate(
          id: 'before',
          nameKey: 'packingTemplateHomePrep',
          groupKey: 'packingTemplateGroupBeforeLeaving',
        ),
        sampleSystemTemplate(
          id: 'transport',
          nameKey: 'packingTemplateAirTravel',
          groupKey: 'packingTemplateGroupTransport',
        ),
        sampleSystemTemplate(
          id: 'essentials',
          nameKey: 'packingTemplateBasicTrip',
          groupKey: 'packingTemplateGroupEssentials',
        ),
        sampleSystemTemplate(
          id: 'trip_type',
          nameKey: 'packingTemplateBeach',
          groupKey: 'packingTemplateGroupTripType',
        ),
        sampleSystemTemplate(
          id: 'travellers',
          nameKey: 'packingTemplateWithChild',
          groupKey: 'packingTemplateGroupTravellers',
        ),
      ];

      final sections = PackingTemplateGrouping.groupSystemTemplates(templates);

      expect(sections.map((section) => section.groupKey).toList(), [
        'packingTemplateGroupTransport',
        'packingTemplateGroupEssentials',
        'packingTemplateGroupTripType',
        'packingTemplateGroupTravellers',
        'packingTemplateGroupBeforeLeaving',
      ]);
    });

    test('places unknown groupKey in other bucket', () {
      final templates = [
        sampleSystemTemplate(
          id: 'unknown',
          nameKey: 'packingTemplateBasicTrip',
          groupKey: 'packingTemplateGroupUnknown',
        ),
      ];

      final sections = PackingTemplateGrouping.groupSystemTemplates(templates);

      expect(sections, hasLength(1));
      expect(sections.single.groupKey, PackingTemplateGrouping.otherGroupKey);
      expect(sections.single.templates.single.id, 'unknown');
    });

    test('places missing groupKey in other bucket', () {
      final templates = [
        sampleSystemTemplate(
          id: 'missing',
          nameKey: 'packingTemplateBasicTrip',
        ),
      ];

      final sections = PackingTemplateGrouping.groupSystemTemplates(templates);

      expect(sections.single.groupKey, PackingTemplateGrouping.otherGroupKey);
    });

    test('preserves repository order within each group', () {
      final templates = [
        sampleSystemTemplate(
          id: 'transport_a',
          nameKey: 'packingTemplateAirTravel',
          groupKey: 'packingTemplateGroupTransport',
        ),
        sampleSystemTemplate(
          id: 'transport_b',
          nameKey: 'packingTemplateTrainBus',
          groupKey: 'packingTemplateGroupTransport',
        ),
      ];

      final sections = PackingTemplateGrouping.groupSystemTemplates(templates);

      expect(
        sections.single.templates.map((template) => template.id).toList(),
        ['transport_a', 'transport_b'],
      );
    });

    test('counts selected templates in a group', () {
      final templates = [
        sampleSystemTemplate(
          id: 'tpl_1',
          groupKey: 'packingTemplateGroupEssentials',
        ),
        sampleSystemTemplate(
          id: 'tpl_2',
          groupKey: 'packingTemplateGroupEssentials',
        ),
      ];

      expect(
        PackingTemplateGrouping.selectedCountInGroup(templates, const {
          'tpl_2',
        }),
        1,
      );
    });

    test('omits empty groups', () {
      final templates = [
        sampleSystemTemplate(
          id: 'transport',
          groupKey: 'packingTemplateGroupTransport',
        ),
      ];

      final sections = PackingTemplateGrouping.groupSystemTemplates(templates);

      expect(sections, hasLength(1));
      expect(sections.single.groupKey, 'packingTemplateGroupTransport');
    });
  });
}
