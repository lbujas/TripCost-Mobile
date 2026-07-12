import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/services/packing_pdf_labels.dart';

PackingPdfLabels packingPdfLabelsFromL10n(AppLocalizations l10n) {
  return PackingPdfLabels(
    packingListTitle: l10n.packingPdfPackingList,
    generatedOn: l10n.packingPdfGeneratedOn,
    totalItems: l10n.packingPdfTotalItems,
    packedItems: l10n.packingPdfPackedItems,
    purchasedItems: l10n.packingPdfPurchasedItems,
    important: l10n.packingPdfImportant,
    critical: l10n.packingPdfCritical,
    toBuy: l10n.packingPdfToBuy,
    page: l10n.packingPdfPage,
    appName: l10n.appTitle,
    departureDate: l10n.packingDepartureDate,
    returnDate: l10n.packingReturnDate,
    descriptionLabel: l10n.packingListDescription,
  );
}
