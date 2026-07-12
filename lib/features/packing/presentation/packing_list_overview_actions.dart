import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_list_helpers.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_lists_controller.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/packing_list_duplicate_helper.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_pdf_options_screen.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';

Future<void> openPackingListPdfExport(
  BuildContext context,
  PackingList list,
) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => PackingPdfOptionsScreen(list: list),
    ),
  );
}

Future<void> duplicatePackingListFromOverview(
  BuildContext context,
  WidgetRef ref,
  PackingList list,
) async {
  final l10n = AppLocalizations.of(context);
  final copiedName = '${list.name}${l10n.packingListCopySuffix}';
  final duplicate = duplicatePackingList(list, copiedName: copiedName);

  try {
    await ref
        .read(packingListsControllerProvider.notifier)
        .savePackingList(duplicate);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.packingListDuplicated)));
  } catch (_) {
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.failedSavePackingList)));
  }
}

Future<void> showRenamePackingListDialog(
  BuildContext context,
  WidgetRef ref,
  PackingList list,
) async {
  final result = await showDialog<({String name, String description})>(
    context: context,
    builder: (dialogContext) => _RenamePackingListDialog(list: list),
  );

  if (result == null || !context.mounted) {
    return;
  }

  final l10n = AppLocalizations.of(context);
  final trimmedName = result.name.trim();
  final trimmedDescription = result.description.trim();

  if (trimmedName.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.packingListNameRequired)));
    return;
  }

  final updated = copyPackingList(
    list,
    name: trimmedName,
    description: trimmedDescription.isEmpty ? null : trimmedDescription,
    clearDescription: trimmedDescription.isEmpty,
  );

  try {
    await ref
        .read(packingListsControllerProvider.notifier)
        .savePackingList(updated);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.packingListRenamed)));
  } catch (_) {
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.failedSavePackingList)));
  }
}

class _RenamePackingListDialog extends StatefulWidget {
  const _RenamePackingListDialog({required this.list});

  final PackingList list;

  @override
  State<_RenamePackingListDialog> createState() =>
      _RenamePackingListDialogState();
}

class _RenamePackingListDialogState extends State<_RenamePackingListDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.list.name);
    _descriptionController = TextEditingController(
      text: widget.list.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop((
      name: _nameController.text,
      description: _descriptionController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.renamePackingList),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.packingListName),
              autofocus: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.packingListDescription,
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

Future<void> showDeletePackingListConfirmation(
  BuildContext context,
  WidgetRef ref,
  PackingList list,
) async {
  final l10n = AppLocalizations.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: Text(l10n.deletePackingListQuestion),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.deletePackingListAboutToDelete),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '"${list.name}"',
                style: Theme.of(dialogContext).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.packingListDeleteCannotUndo),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        ),
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  try {
    await ref
        .read(packingListRepositoryProvider)
        .deletePackingListSoft(list.id);
    ref.invalidate(packingListsControllerProvider);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.packingListDeleted)));
  } catch (_) {
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.failedSavePackingList)));
  }
}
