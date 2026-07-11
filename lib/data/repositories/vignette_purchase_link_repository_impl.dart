import 'package:travel_cost_planner_europe/data/sources/vignette_purchase_link_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/selected_vignette.dart';
import 'package:travel_cost_planner_europe/domain/models/vignette_purchase_link.dart';
import 'package:travel_cost_planner_europe/domain/repositories/vignette_purchase_link_repository.dart';

class VignettePurchaseLinkRepositoryImpl implements VignettePurchaseLinkRepository {
  const VignettePurchaseLinkRepositoryImpl(this._localSource);

  final VignettePurchaseLinkLocalSource _localSource;

  static const Set<String> _excludedCountryCodes = {'PL', 'HR'};

  @override
  Future<List<VignettePurchaseLink>> getAllPurchaseLinks() {
    return _localSource.getAllPurchaseLinks();
  }

  @override
  Future<List<VignettePurchaseEntry>> getPurchaseEntriesForVignettes(
    List<SelectedVignette> vignettes,
  ) async {
    final links = await getAllPurchaseLinks();
    final linksByCountry = {
      for (final link in links) link.countryCode.toUpperCase(): link,
    };

    final entries = <VignettePurchaseEntry>[];
    for (final vignette in vignettes) {
      final countryCode = vignette.countryCode.toUpperCase();
      if (_excludedCountryCodes.contains(countryCode)) {
        continue;
      }

      final link = linksByCountry[countryCode];
      if (link != null) {
        entries.add(VignettePurchaseEntry(vignette: vignette, link: link));
      }
    }

    return entries;
  }
}
