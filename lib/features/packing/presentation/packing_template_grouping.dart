import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';

/// Presentation-only grouping for system packing templates.
class PackingTemplateGrouping {
  PackingTemplateGrouping._();

  static const orderedSystemGroupKeys = [
    'packingTemplateGroupTransport',
    'packingTemplateGroupEssentials',
    'packingTemplateGroupTripType',
    'packingTemplateGroupTravellers',
    'packingTemplateGroupBeforeLeaving',
  ];

  /// Sentinel for templates with a missing or unknown [PackingTemplate.groupKey].
  static const otherGroupKey = '__packing_template_group_other__';

  static bool isKnownSystemGroupKey(String? groupKey) {
    return groupKey != null && orderedSystemGroupKeys.contains(groupKey);
  }

  static List<PackingTemplateGroupSection> groupSystemTemplates(
    List<PackingTemplate> templates,
  ) {
    final buckets = {
      for (final key in orderedSystemGroupKeys) key: <PackingTemplate>[],
      otherGroupKey: <PackingTemplate>[],
    };

    for (final template in templates) {
      final groupKey = template.groupKey;
      if (isKnownSystemGroupKey(groupKey)) {
        buckets[groupKey!]!.add(template);
      } else {
        buckets[otherGroupKey]!.add(template);
      }
    }

    final sections = <PackingTemplateGroupSection>[];
    for (final key in orderedSystemGroupKeys) {
      final groupTemplates = buckets[key]!;
      if (groupTemplates.isNotEmpty) {
        sections.add(
          PackingTemplateGroupSection(
            groupKey: key,
            templates: List.unmodifiable(groupTemplates),
          ),
        );
      }
    }

    final otherTemplates = buckets[otherGroupKey]!;
    if (otherTemplates.isNotEmpty) {
      sections.add(
        PackingTemplateGroupSection(
          groupKey: otherGroupKey,
          templates: List.unmodifiable(otherTemplates),
        ),
      );
    }

    return sections;
  }

  static int selectedCountInGroup(
    List<PackingTemplate> templates,
    Set<String> selectedIds,
  ) {
    return templates
        .where((template) => selectedIds.contains(template.id))
        .length;
  }
}

class PackingTemplateGroupSection {
  const PackingTemplateGroupSection({
    required this.groupKey,
    required this.templates,
  });

  final String groupKey;
  final List<PackingTemplate> templates;
}
