import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_scope.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_priority.dart';

class PackingListExportData {
  const PackingListExportData({
    required this.listName,
    this.description,
    this.departureDate,
    this.returnDate,
    required this.generatedAt,
    required this.totalItems,
    required this.checkedCount,
    required this.scope,
    required this.categories,
  });

  final String listName;
  final String? description;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final DateTime generatedAt;
  final int totalItems;
  final int checkedCount;
  final PackingPdfScope scope;
  final List<PackingExportCategoryGroup> categories;

  bool get isEmpty => totalItems == 0;
}

class PackingExportCategoryGroup {
  const PackingExportCategoryGroup({
    required this.id,
    required this.name,
    required this.items,
  });

  final String id;
  final String name;
  final List<PackingExportItemRow> items;

  int get itemCount => items.length;

  int get checkedCount => items.where((item) => item.isChecked).length;
}

class PackingExportItemRow {
  const PackingExportItemRow({
    required this.name,
    required this.quantity,
    required this.unit,
    this.note,
    this.priority = PackingPriority.normal,
    this.needsPurchase = false,
    this.isPurchased = false,
    required this.isChecked,
  });

  final String name;
  final int quantity;
  final String unit;
  final String? note;
  final PackingPriority priority;
  final bool needsPurchase;
  final bool isPurchased;
  final bool isChecked;
}
