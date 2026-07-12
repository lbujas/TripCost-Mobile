import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_checkbox_mode.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_page_orientation.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_scope.dart';

class PackingPdfOptions {
  const PackingPdfOptions({
    this.scope = PackingPdfScope.fullList,
    this.checkboxMode = PackingCheckboxMode.empty,
    this.selectedCategoryId,
    this.includePurchasedShoppingItems = true,
    this.showDescription = true,
    this.showNotes = true,
    this.showQuantity = true,
    this.showPriority = true,
    this.showPurchaseStatus = true,
    this.showDepartureAndReturnDates = true,
    this.blackAndWhite = true,
    this.startEachCategoryOnNewPage = false,
    this.pageOrientation = PackingPdfPageOrientation.portrait,
  });

  final PackingPdfScope scope;
  final PackingCheckboxMode checkboxMode;
  final String? selectedCategoryId;
  final bool includePurchasedShoppingItems;
  final bool showDescription;
  final bool showNotes;
  final bool showQuantity;
  final bool showPriority;
  final bool showPurchaseStatus;
  final bool showDepartureAndReturnDates;
  final bool blackAndWhite;
  final bool startEachCategoryOnNewPage;
  final PackingPdfPageOrientation pageOrientation;

  bool get requiresCategorySelection =>
      scope == PackingPdfScope.selectedCategory;

  bool get isValid =>
      !requiresCategorySelection ||
      (selectedCategoryId != null && selectedCategoryId!.isNotEmpty);

  PackingPdfOptions copyWith({
    PackingPdfScope? scope,
    PackingCheckboxMode? checkboxMode,
    String? selectedCategoryId,
    bool clearSelectedCategoryId = false,
    bool? includePurchasedShoppingItems,
    bool? showDescription,
    bool? showNotes,
    bool? showQuantity,
    bool? showPriority,
    bool? showPurchaseStatus,
    bool? showDepartureAndReturnDates,
    bool? blackAndWhite,
    bool? startEachCategoryOnNewPage,
    PackingPdfPageOrientation? pageOrientation,
  }) {
    return PackingPdfOptions(
      scope: scope ?? this.scope,
      checkboxMode: checkboxMode ?? this.checkboxMode,
      selectedCategoryId:
          clearSelectedCategoryId
              ? null
              : (selectedCategoryId ?? this.selectedCategoryId),
      includePurchasedShoppingItems:
          includePurchasedShoppingItems ?? this.includePurchasedShoppingItems,
      showDescription: showDescription ?? this.showDescription,
      showNotes: showNotes ?? this.showNotes,
      showQuantity: showQuantity ?? this.showQuantity,
      showPriority: showPriority ?? this.showPriority,
      showPurchaseStatus: showPurchaseStatus ?? this.showPurchaseStatus,
      showDepartureAndReturnDates:
          showDepartureAndReturnDates ?? this.showDepartureAndReturnDates,
      blackAndWhite: blackAndWhite ?? this.blackAndWhite,
      startEachCategoryOnNewPage:
          startEachCategoryOnNewPage ?? this.startEachCategoryOnNewPage,
      pageOrientation: pageOrientation ?? this.pageOrientation,
    );
  }
}
