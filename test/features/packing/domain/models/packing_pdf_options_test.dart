import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_checkbox_mode.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_options.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_page_orientation.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_scope.dart';

void main() {
  group('PackingPdfOptions', () {
    test('safe defaults', () {
      const options = PackingPdfOptions();

      expect(options.scope, PackingPdfScope.fullList);
      expect(options.checkboxMode, PackingCheckboxMode.empty);
      expect(options.includePurchasedShoppingItems, isTrue);
      expect(options.showDescription, isTrue);
      expect(options.showNotes, isTrue);
      expect(options.showQuantity, isTrue);
      expect(options.showPriority, isTrue);
      expect(options.showPurchaseStatus, isTrue);
      expect(options.showDepartureAndReturnDates, isTrue);
      expect(options.blackAndWhite, isTrue);
      expect(options.startEachCategoryOnNewPage, isFalse);
      expect(options.pageOrientation, PackingPdfPageOrientation.portrait);
    });

    test('category requirement for selected-category scope', () {
      const withoutCategory = PackingPdfOptions(
        scope: PackingPdfScope.selectedCategory,
      );
      const withCategory = PackingPdfOptions(
        scope: PackingPdfScope.selectedCategory,
        selectedCategoryId: 'cat-1',
      );

      expect(withoutCategory.isValid, isFalse);
      expect(withCategory.isValid, isTrue);
    });

    test('checkbox modes', () {
      const empty = PackingPdfOptions(checkboxMode: PackingCheckboxMode.empty);
      const current = PackingPdfOptions(
        checkboxMode: PackingCheckboxMode.currentState,
      );

      expect(empty.checkboxMode, PackingCheckboxMode.empty);
      expect(current.checkboxMode, PackingCheckboxMode.currentState);
    });

    test('portrait and landscape settings', () {
      const landscape = PackingPdfOptions(
        pageOrientation: PackingPdfPageOrientation.landscape,
      );

      expect(landscape.pageOrientation, PackingPdfPageOrientation.landscape);
    });
  });
}
