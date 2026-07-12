/// Localized strings used when rendering a packing list PDF.
class PackingPdfLabels {
  const PackingPdfLabels({
    required this.packingListTitle,
    required this.generatedOn,
    required this.totalItems,
    required this.packedItems,
    required this.purchasedItems,
    required this.important,
    required this.critical,
    required this.toBuy,
    required this.page,
    required this.appName,
    required this.departureDate,
    required this.returnDate,
    required this.descriptionLabel,
  });

  final String packingListTitle;
  final String generatedOn;
  final String totalItems;
  final String packedItems;
  final String purchasedItems;
  final String important;
  final String critical;
  final String toBuy;
  final String page;
  final String appName;
  final String departureDate;
  final String returnDate;
  final String descriptionLabel;

  String formatGeneratedOn(DateTime date) => '$generatedOn $date';

  String formatTotalItems(int count) => '$totalItems: $count';

  String formatPackedItems(int count) => '$packedItems: $count';

  String formatPurchasedItems(int count) => '$purchasedItems: $count';

  String formatPage(int pageNumber, int pageCount) =>
      '$page $pageNumber / $pageCount';
}

String sanitizePackingPdfFilename(String listName) {
  final sanitized = listName.replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '_').trim();
  if (sanitized.isEmpty) {
    return 'packing_list';
  }
  return sanitized;
}
