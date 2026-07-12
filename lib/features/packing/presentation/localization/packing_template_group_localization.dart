import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/localization/packing_template_localization.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/packing_template_grouping.dart';

String resolvePackingTemplateGroupTitle(
  AppLocalizations l10n,
  String groupKey,
) {
  if (groupKey == PackingTemplateGrouping.otherGroupKey) {
    return l10n.packingTemplateGroupOther;
  }

  return resolvePackingTemplateKey(l10n, groupKey);
}

String resolvePackingTemplateGroupHint(AppLocalizations l10n, String groupKey) {
  switch (groupKey) {
    case 'packingTemplateGroupTransport':
      return l10n.packingTemplateGroupTransportHint;
    case 'packingTemplateGroupEssentials':
      return l10n.packingTemplateGroupEssentialsHint;
    case 'packingTemplateGroupTripType':
      return l10n.packingTemplateGroupTripTypeHint;
    case 'packingTemplateGroupTravellers':
      return l10n.packingTemplateGroupTravellersHint;
    case 'packingTemplateGroupBeforeLeaving':
      return l10n.packingTemplateGroupBeforeLeavingHint;
    case PackingTemplateGrouping.otherGroupKey:
      return l10n.packingTemplateGroupOtherHint;
    default:
      return l10n.packingTemplateGroupOtherHint;
  }
}
