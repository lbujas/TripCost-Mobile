import 'package:travel_cost_planner_europe/domain/models/selected_vignette.dart';
import 'package:travel_cost_planner_europe/domain/models/vignette_purchase_link.dart';

class VignettePurchaseEntry {
  const VignettePurchaseEntry({
    required this.vignette,
    required this.link,
  });

  final SelectedVignette vignette;
  final VignettePurchaseLink link;
}

abstract class VignettePurchaseLinkRepository {
  Future<List<VignettePurchaseLink>> getAllPurchaseLinks();

  Future<List<VignettePurchaseEntry>> getPurchaseEntriesForVignettes(
    List<SelectedVignette> vignettes,
  );
}
