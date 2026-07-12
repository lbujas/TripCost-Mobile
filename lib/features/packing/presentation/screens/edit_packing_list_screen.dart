import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_list_detail_controller.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_button.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_text_field.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';

class EditPackingListScreen extends ConsumerStatefulWidget {
  const EditPackingListScreen({super.key, required this.packingListId});

  final String packingListId;

  @override
  ConsumerState<EditPackingListScreen> createState() =>
      _EditPackingListScreenState();
}

class _EditPackingListScreenState extends ConsumerState<EditPackingListScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _initialized = false;
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

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);

    if (_nameController.text.trim().isEmpty) {
      _showError(l10n.packingListNameRequired);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(
            packingListDetailControllerProvider(widget.packingListId).notifier,
          )
          .updateListMetadata(
            name: _nameController.text,
            description: _descriptionController.text,
          );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
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

      _nameController.text = list.name;
      _descriptionController.text = list.description ?? '';
      _initialized = true;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editPackingList),
        actions: const [SettingsActionButton()],
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.failedLoadPackingList)),
        data:
            (_) => ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
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
                AppButton(
                  label: l10n.save,
                  onPressed: _isSaving ? null : _save,
                ),
              ],
            ),
      ),
    );
  }
}
