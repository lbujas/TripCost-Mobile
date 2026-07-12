import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_priority.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_list_detail_controller.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_button.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_text_field.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';

const _newCategoryValue = '__new_category__';

class PackingItemFormScreen extends ConsumerStatefulWidget {
  const PackingItemFormScreen({
    super.key,
    required this.packingListId,
    this.itemId,
  });

  final String packingListId;
  final String? itemId;

  bool get isEditing => itemId != null;

  @override
  ConsumerState<PackingItemFormScreen> createState() =>
      _PackingItemFormScreenState();
}

class _PackingItemFormScreenState extends ConsumerState<PackingItemFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _noteController;
  late final TextEditingController _newCategoryController;

  String? _selectedCategoryId;
  PackingPriority _priority = PackingPriority.normal;
  bool _needsPurchase = false;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _quantityController = TextEditingController(text: '1');
    _unitController = TextEditingController(text: 'piece');
    _noteController = TextEditingController();
    _newCategoryController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _priorityLabel(AppLocalizations l10n, PackingPriority priority) {
    switch (priority) {
      case PackingPriority.normal:
        return l10n.packingPriorityNormal;
      case PackingPriority.important:
        return l10n.packingPriorityImportant;
      case PackingPriority.critical:
        return l10n.packingPriorityCritical;
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final quantity = int.tryParse(_quantityController.text.trim());

    if (_nameController.text.trim().isEmpty) {
      _showError(l10n.packingItemNameRequired);
      return;
    }

    if (_selectedCategoryId == null) {
      _showError(l10n.packingCategoryRequired);
      return;
    }

    if (_selectedCategoryId == _newCategoryValue &&
        _newCategoryController.text.trim().isEmpty) {
      _showError(l10n.packingCategoryRequired);
      return;
    }

    if (quantity == null || quantity <= 0) {
      _showError(l10n.packingQuantityMustBePositive);
      return;
    }

    if (_unitController.text.trim().isEmpty) {
      _showError(l10n.packingUnitRequired);
      return;
    }

    setState(() => _isSaving = true);

    final notifier = ref.read(
      packingListDetailControllerProvider(widget.packingListId).notifier,
    );

    try {
      final isNewCategory = _selectedCategoryId == _newCategoryValue;

      if (widget.isEditing) {
        await notifier.updateItem(
          itemId: widget.itemId!,
          name: _nameController.text,
          categoryId: isNewCategory ? null : _selectedCategoryId,
          newCategoryName: isNewCategory ? _newCategoryController.text : null,
          quantity: quantity,
          unit: _unitController.text,
          priority: _priority,
          needsPurchase: _needsPurchase,
          note: _noteController.text,
        );
      } else {
        await notifier.addItem(
          name: _nameController.text,
          categoryId: isNewCategory ? null : _selectedCategoryId,
          newCategoryName: isNewCategory ? _newCategoryController.text : null,
          quantity: quantity,
          unit: _unitController.text,
          priority: _priority,
          needsPurchase: _needsPurchase,
          note: _noteController.text,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      switch (error.message) {
        case 'name':
          _showError(l10n.packingItemNameRequired);
        case 'category':
          _showError(l10n.packingCategoryRequired);
        case 'quantity':
          _showError(l10n.packingQuantityMustBePositive);
        case 'unit':
          _showError(l10n.packingUnitRequired);
        default:
          _showError(l10n.failedSavePackingList);
      }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listAsync = ref.watch(
      packingListDetailControllerProvider(widget.packingListId),
    );

    listAsync.whenData((list) {
      if (_initialized) {
        return;
      }

      if (widget.isEditing) {
        final item = list.items.firstWhere(
          (entry) => entry.id == widget.itemId,
        );
        _nameController.text = item.name;
        _quantityController.text = item.quantity.toString();
        _unitController.text = item.unit;
        _noteController.text = item.note ?? '';
        _selectedCategoryId = item.categoryId;
        _priority = item.priority;
        _needsPurchase = item.needsPurchase;
      } else if (list.customCategories.isEmpty) {
        _selectedCategoryId = _newCategoryValue;
      } else {
        _selectedCategoryId = list.customCategories.first.id;
      }

      _initialized = true;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? l10n.editPackingItem : l10n.addPackingItem,
        ),
        actions: const [SettingsActionButton()],
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.failedLoadPackingList)),
        data: (list) {
          final categories = list.customCategories;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AppTextField(
                controller: _nameController,
                label: l10n.packingItemName,
                prefixIcon: Icons.checklist_outlined,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: l10n.packingCategory,
                  prefixIcon: Icon(
                    Icons.category_outlined,
                    size: 22,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                items: [
                  ...categories.map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  ),
                  DropdownMenuItem(
                    value: _newCategoryValue,
                    child: Text(l10n.packingNewCategory),
                  ),
                ],
                onChanged:
                    (value) => setState(() => _selectedCategoryId = value),
              ),
              if (_selectedCategoryId == _newCategoryValue) ...[
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _newCategoryController,
                  label: l10n.packingCategoryName,
                  prefixIcon: Icons.create_new_folder_outlined,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _quantityController,
                label: l10n.packingQuantity,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefixIcon: Icons.numbers,
              ),
              AppTextField(
                controller: _unitController,
                label: l10n.packingUnit,
                prefixIcon: Icons.straighten_outlined,
              ),
              DropdownButtonFormField<PackingPriority>(
                value: _priority,
                decoration: InputDecoration(
                  labelText: l10n.packingPriority,
                  prefixIcon: Icon(
                    Icons.flag_outlined,
                    size: 22,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                items:
                    PackingPriority.values
                        .map(
                          (priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(_priorityLabel(l10n, priority)),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) => setState(() => _priority = value ?? _priority),
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.packingNeedsPurchase),
                value: _needsPurchase,
                onChanged: (value) => setState(() => _needsPurchase = value),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.packingNote,
                    prefixIcon: Icon(
                      Icons.notes_outlined,
                      size: 22,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: listAsync.maybeWhen(
        data:
            (_) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppButton(
                  label: l10n.save,
                  onPressed: _isSaving ? null : _save,
                ),
              ),
            ),
        orElse: () => null,
      ),
    );
  }
}
