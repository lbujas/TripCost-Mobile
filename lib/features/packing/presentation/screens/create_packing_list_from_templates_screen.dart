import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_lists_controller.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_template_selection_controller.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/localization/packing_template_localization.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/widgets/packing_template_selection_summary.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_button.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_text_field.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';

class CreatePackingListFromTemplatesScreen extends ConsumerStatefulWidget {
  const CreatePackingListFromTemplatesScreen({super.key});

  @override
  ConsumerState<CreatePackingListFromTemplatesScreen> createState() =>
      _CreatePackingListFromTemplatesScreenState();
}

class _CreatePackingListFromTemplatesScreenState
    extends ConsumerState<CreatePackingListFromTemplatesScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  DateTime? _departureDate;
  DateTime? _returnDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDate({required bool isDeparture}) async {
    final initialDate =
        isDeparture
            ? (_departureDate ?? DateTime.now())
            : (_returnDate ?? _departureDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      if (isDeparture) {
        _departureDate = picked;
        if (_returnDate != null && _returnDate!.isBefore(picked)) {
          _returnDate = null;
        }
      } else {
        _returnDate = picked;
      }
    });
  }

  void _clearDate({required bool isDeparture}) {
    setState(() {
      if (isDeparture) {
        _departureDate = null;
      } else {
        _returnDate = null;
      }
    });
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final selectionController = ref.read(
      packingTemplateSelectionControllerProvider.notifier,
    );
    final selectedTemplates = selectionController.selectedTemplates();

    if (selectedTemplates.isEmpty) {
      _showError(l10n.packingSelectAtLeastOneTemplate);
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError(l10n.packingListNameRequired);
      return;
    }

    if (_departureDate != null &&
        _returnDate != null &&
        _returnDate!.isBefore(_departureDate!)) {
      _showError(l10n.packingReturnDateBeforeDeparture);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now().toUtc();
      final listId = 'packing_list_${now.microsecondsSinceEpoch}';
      var idCounter = 0;
      final createService = ref.read(packingListFromTemplatesServiceProvider);
      final localizationResolver = packingTemplateLocalizationResolver(l10n);

      final list = createService.create(
        templates: selectedTemplates,
        packingListId: listId,
        listName: name,
        description: _descriptionController.text,
        departureDate: _departureDate,
        returnDate: _returnDate,
        createdAt: now,
        idGenerator: (prefix) {
          idCounter++;
          return '${prefix}_$idCounter';
        },
        localizationResolver: localizationResolver,
      );

      await ref
          .read(packingListsControllerProvider.notifier)
          .savePackingList(list);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(list.id);
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showError(l10n.failedSavePackingList);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) {
      return '';
    }

    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectionController = ref.read(
      packingTemplateSelectionControllerProvider.notifier,
    );
    final selectedCount = ref
        .watch(packingTemplateSelectionControllerProvider)
        .maybeWhen(
          data: (selection) => selection.selectedCount,
          orElse: () => 0,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.packingCreateList),
        actions: const [SettingsActionButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          PackingTemplateSelectionSummary(
            selectedCount: selectedCount,
            mergedItemCount: selectionController.mergedItemCount(),
            mergedCategoryCount: selectionController.mergedCategoryCount(),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _nameController,
            label: l10n.packingListName,
            prefixIcon: Icons.luggage_outlined,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.packingListDescription,
                prefixIcon: Icon(
                  Icons.notes_outlined,
                  size: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.packingDepartureDate),
            subtitle:
                _departureDate == null
                    ? null
                    : Text(_formatDate(context, _departureDate)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_departureDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: l10n.packingClearDate,
                    onPressed: () => _clearDate(isDeparture: true),
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: () => _pickDate(isDeparture: true),
                ),
              ],
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.packingReturnDate),
            subtitle:
                _returnDate == null
                    ? null
                    : Text(_formatDate(context, _returnDate)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_returnDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: l10n.packingClearDate,
                    onPressed: () => _clearDate(isDeparture: false),
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: () => _pickDate(isDeparture: false),
                ),
              ],
            ),
          ),
          AppButton(
            label: l10n.packingCreateList,
            onPressed: _isSaving ? null : _create,
          ),
        ],
      ),
    );
  }
}
