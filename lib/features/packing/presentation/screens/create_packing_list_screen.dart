import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_lists_controller.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_button.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_text_field.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';

class CreatePackingListScreen extends ConsumerStatefulWidget {
  const CreatePackingListScreen({super.key});

  @override
  ConsumerState<CreatePackingListScreen> createState() =>
      _CreatePackingListScreenState();
}

class _CreatePackingListScreenState
    extends ConsumerState<CreatePackingListScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
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
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showError(l10n.packingListNameRequired);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final created = await ref
          .read(packingListsControllerProvider.notifier)
          .createPackingList(
            name: _nameController.text,
            description: _descriptionController.text,
          );

      if (!mounted) {
        return;
      }

      if (!created) {
        _showError(l10n.packingListNameRequired);
        return;
      }

      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newPackingList),
        actions: const [SettingsActionButton()],
      ),
      body: ListView(
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
          AppButton(label: l10n.save, onPressed: _isSaving ? null : _save),
        ],
      ),
    );
  }
}
