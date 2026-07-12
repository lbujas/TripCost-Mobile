import 'package:travel_cost_planner_europe/features/packing/presentation/services/packing_list_pdf_service.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/services/packing_pdf_fonts.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/services/packing_pdf_labels.dart';

Future<PackingListPdfService> createTestPackingListPdfService() async {
  final fonts = await PackingPdfFonts.load();
  return PackingListPdfService(fonts);
}

const testPackingPdfLabels = PackingPdfLabels(
  packingListTitle: 'Packing list',
  generatedOn: 'Generated on',
  totalItems: 'Total items',
  packedItems: 'Packed items',
  purchasedItems: 'Purchased items',
  important: 'IMPORTANT',
  critical: 'CRITICAL',
  toBuy: 'To buy',
  page: 'Page',
  appName: 'TripCost',
  departureDate: 'Departure date',
  returnDate: 'Return date',
  descriptionLabel: 'Description',
);

/// Sample strings covering all supported app locales / scripts.
const centralEuropeanPdfSampleStrings = [
  'ą ć ę ł ń ó ś ź ż', // Polish
  'Wycieczka nad morze',
  'Straße und Größe', // German
  'Český seznam a říjen', // Czech
  'Slovenský zoznam a dôvera', // Slovak
  'Hrvatski popis i voćnjak', // Croatian
  'Magyar lista és köszönöm', // Hungarian
];
