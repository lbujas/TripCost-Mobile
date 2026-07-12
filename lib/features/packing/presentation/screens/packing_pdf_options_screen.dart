import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_checkbox_mode.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_options.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_page_orientation.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_scope.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_list_export_data_builder.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_list_helpers.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_pdf_preview_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/services/packing_pdf_labels_mapper.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_button.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';

class PackingPdfOptionsScreen extends ConsumerStatefulWidget {
  const PackingPdfOptionsScreen({super.key, required this.list});

  final PackingList list;

  @override
  ConsumerState<PackingPdfOptionsScreen> createState() =>
      _PackingPdfOptionsScreenState();
}

class _PackingPdfOptionsScreenState
    extends ConsumerState<PackingPdfOptionsScreen> {
  static const _builder = PackingListExportDataBuilder();

  PackingPdfOptions _options = const PackingPdfOptions();
  bool _isOpeningPreview = false;

  List<PackingCategoryOption> get _categories {
    return packingSortedCategoriesWithActiveItems(widget.list)
        .map(
          (category) =>
              PackingCategoryOption(id: category.id, name: category.name),
        )
        .toList();
  }

  int get _exportItemCount {
    return _builder.build(list: widget.list, options: _options).totalItems;
  }

  void _updateOptions(PackingPdfOptions options) {
    setState(() => _options = options);
  }

  Future<Uint8List> _generatePdfBytes() async {
    final l10n = AppLocalizations.of(context);
    final service = await ref.read(packingListPdfServiceProvider.future);
    final labels = packingPdfLabelsFromL10n(l10n);
    final exportData = _builder.build(list: widget.list, options: _options);

    return service.generate(
      data: exportData,
      options: _options,
      labels: labels,
    );
  }

  Future<void> _openPreview() async {
    final l10n = AppLocalizations.of(context);

    if (!_options.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.packingPdfSelectCategoryRequired)),
      );
      return;
    }

    if (_exportItemCount == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.packingPdfNoItemsMatch)));
      return;
    }

    setState(() => _isOpeningPreview = true);

    try {
      final generatedPdf = await _generatePdfBytes();
      if (!mounted) {
        return;
      }

      try {
        await ref.read(adServiceProvider).showInterstitialIfLoaded();
      } catch (_) {
        // Interstitial presentation must never block PDF preview.
      }
      if (!mounted) {
        return;
      }

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder:
              (context) => PackingPdfPreviewScreen(
                list: widget.list,
                options: _options,
                generatedPdf: generatedPdf,
              ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isOpeningPreview = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = _categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.packingPdfOptions),
        actions: const [SettingsActionButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            l10n.packingPdfScopeSection,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...PackingPdfScope.values.map(
            (scope) => RadioListTile<PackingPdfScope>(
              title: Text(_scopeLabel(l10n, scope)),
              value: scope,
              groupValue: _options.scope,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                _updateOptions(
                  _options.copyWith(
                    scope: value,
                    clearSelectedCategoryId:
                        value != PackingPdfScope.selectedCategory,
                  ),
                );
              },
            ),
          ),
          if (_options.scope == PackingPdfScope.selectedCategory) ...[
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value:
                  categories.any((c) => c.id == _options.selectedCategoryId)
                      ? _options.selectedCategoryId
                      : null,
              decoration: InputDecoration(
                labelText: l10n.packingPdfSelectedCategory,
              ),
              items:
                  categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
              onChanged:
                  (value) => _updateOptions(
                    _options.copyWith(selectedCategoryId: value),
                  ),
            ),
          ],
          if (_options.scope == PackingPdfScope.shoppingList)
            SwitchListTile(
              title: Text(l10n.packingPdfIncludePurchasedItems),
              value: _options.includePurchasedShoppingItems,
              onChanged:
                  (value) => _updateOptions(
                    _options.copyWith(includePurchasedShoppingItems: value),
                  ),
            ),
          const Divider(height: AppSpacing.xl),
          Text(
            l10n.packingPdfCheckboxSection,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          RadioListTile<PackingCheckboxMode>(
            title: Text(l10n.packingPdfEmptyCheckboxes),
            subtitle: Text(l10n.packingPdfEmptyCheckboxesDesc),
            value: PackingCheckboxMode.empty,
            groupValue: _options.checkboxMode,
            onChanged:
                (value) =>
                    value == null
                        ? null
                        : _updateOptions(
                          _options.copyWith(checkboxMode: value),
                        ),
          ),
          RadioListTile<PackingCheckboxMode>(
            title: Text(l10n.packingPdfCurrentState),
            subtitle: Text(l10n.packingPdfCurrentStateDesc),
            value: PackingCheckboxMode.currentState,
            groupValue: _options.checkboxMode,
            onChanged:
                (value) =>
                    value == null
                        ? null
                        : _updateOptions(
                          _options.copyWith(checkboxMode: value),
                        ),
          ),
          const Divider(height: AppSpacing.xl),
          Text(
            l10n.packingPdfContentSection,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SwitchListTile(
            title: Text(l10n.packingPdfShowDescription),
            value: _options.showDescription,
            onChanged:
                (value) =>
                    _updateOptions(_options.copyWith(showDescription: value)),
          ),
          SwitchListTile(
            title: Text(l10n.packingPdfShowNotes),
            value: _options.showNotes,
            onChanged:
                (value) => _updateOptions(_options.copyWith(showNotes: value)),
          ),
          SwitchListTile(
            title: Text(l10n.packingPdfShowQuantity),
            value: _options.showQuantity,
            onChanged:
                (value) =>
                    _updateOptions(_options.copyWith(showQuantity: value)),
          ),
          SwitchListTile(
            title: Text(l10n.packingPdfShowPriority),
            value: _options.showPriority,
            onChanged:
                (value) =>
                    _updateOptions(_options.copyWith(showPriority: value)),
          ),
          SwitchListTile(
            title: Text(l10n.packingPdfShowPurchaseStatus),
            value: _options.showPurchaseStatus,
            onChanged:
                (value) => _updateOptions(
                  _options.copyWith(showPurchaseStatus: value),
                ),
          ),
          SwitchListTile(
            title: Text(l10n.packingPdfShowTravelDates),
            value: _options.showDepartureAndReturnDates,
            onChanged:
                (value) => _updateOptions(
                  _options.copyWith(showDepartureAndReturnDates: value),
                ),
          ),
          const Divider(height: AppSpacing.xl),
          Text(
            l10n.packingPdfLayoutSection,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          RadioListTile<PackingPdfPageOrientation>(
            title: Text(l10n.packingPdfPortrait),
            value: PackingPdfPageOrientation.portrait,
            groupValue: _options.pageOrientation,
            onChanged:
                (value) =>
                    value == null
                        ? null
                        : _updateOptions(
                          _options.copyWith(pageOrientation: value),
                        ),
          ),
          RadioListTile<PackingPdfPageOrientation>(
            title: Text(l10n.packingPdfLandscape),
            value: PackingPdfPageOrientation.landscape,
            groupValue: _options.pageOrientation,
            onChanged:
                (value) =>
                    value == null
                        ? null
                        : _updateOptions(
                          _options.copyWith(pageOrientation: value),
                        ),
          ),
          SwitchListTile(
            title: Text(l10n.packingPdfStartCategoryOnNewPage),
            value: _options.startEachCategoryOnNewPage,
            onChanged:
                (value) => _updateOptions(
                  _options.copyWith(startEachCategoryOnNewPage: value),
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.packingPdfItemsAfterOptions(_exportItemCount),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            key: const Key('packing_pdf_preview_button'),
            label: l10n.packingPdfPreview,
            isLoading: _isOpeningPreview,
            onPressed:
                !_isOpeningPreview && _options.isValid && _exportItemCount > 0
                    ? _openPreview
                    : null,
          ),
        ],
      ),
    );
  }

  String _scopeLabel(AppLocalizations l10n, PackingPdfScope scope) {
    switch (scope) {
      case PackingPdfScope.fullList:
        return l10n.packingPdfScopeFullList;
      case PackingPdfScope.unpackedOnly:
        return l10n.packingPdfScopeUnpacked;
      case PackingPdfScope.shoppingList:
        return l10n.packingPdfScopeShoppingList;
      case PackingPdfScope.packedItems:
        return l10n.packingPdfScopePackedItems;
      case PackingPdfScope.selectedCategory:
        return l10n.packingPdfScopeSelectedCategory;
    }
  }
}

class PackingCategoryOption {
  const PackingCategoryOption({required this.id, required this.name});

  final String id;
  final String name;
}
