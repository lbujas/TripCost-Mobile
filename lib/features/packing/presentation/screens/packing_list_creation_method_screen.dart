import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/create_packing_list_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_template_selection_screen.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';

class PackingListCreationMethodScreen extends StatelessWidget {
  const PackingListCreationMethodScreen({super.key});

  Future<void> _openBlankList(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => const CreatePackingListScreen(),
      ),
    );

    if (created == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _openTemplateFlow(BuildContext context) async {
    final listId = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (context) => const PackingTemplateSelectionScreen(),
      ),
    );

    if (listId != null && context.mounted) {
      Navigator.of(context).pop(listId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createPackingList),
        actions: const [SettingsActionButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            onTap: () => _openBlankList(context),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(Icons.note_add_outlined),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(l10n.packingCreateBlankList)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            onTap: () => _openTemplateFlow(context),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(Icons.library_add_outlined),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(l10n.packingCreateFromTemplates)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
