import 'package:flutter/material.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/packing_template_grouping.dart';

IconData resolvePackingTemplateGroupIcon(String groupKey) {
  switch (groupKey) {
    case 'packingTemplateGroupTransport':
      return Icons.directions_outlined;
    case 'packingTemplateGroupEssentials':
      return Icons.backpack_outlined;
    case 'packingTemplateGroupTripType':
      return Icons.explore_outlined;
    case 'packingTemplateGroupTravellers':
      return Icons.group_outlined;
    case 'packingTemplateGroupBeforeLeaving':
      return Icons.home_work_outlined;
    case PackingTemplateGrouping.otherGroupKey:
      return Icons.more_horiz;
    default:
      return Icons.more_horiz;
  }
}
