import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/core/utils/country_localization_service.dart';
import 'package:travel_cost_planner_europe/core/utils/vignette_purchase_localization_service.dart';
import 'package:travel_cost_planner_europe/domain/models/selected_vignette.dart';
import 'package:travel_cost_planner_europe/domain/repositories/vignette_purchase_link_repository.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_button.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/cost_row.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/section_title.dart';
import 'package:url_launcher/url_launcher.dart';

class VignettePurchaseLinksSection extends ConsumerWidget {
  const VignettePurchaseLinksSection({
    super.key,
    required this.selectedVignettes,
  });

  final List<SelectedVignette> selectedVignettes;

  Future<void> _openOfficialWebsite(
    BuildContext context,
    String url,
  ) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).couldNotOpenLink),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectedVignettes.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final entriesAsync = ref.watch(
      vignettePurchaseEntriesProvider(selectedVignettes),
    );

    return entriesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (entries) {
        if (entries.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            SectionTitle(title: l10n.buyRequiredVignettesOnline),
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _VignettePurchaseCard(
                  entry: entry,
                  textStyles: textStyles,
                  colorScheme: colorScheme,
                  l10n: l10n,
                  onOpenWebsite: () => _openOfficialWebsite(
                    context,
                    entry.link.officialPurchaseUrl,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VignettePurchaseCard extends StatelessWidget {
  const _VignettePurchaseCard({
    required this.entry,
    required this.textStyles,
    required this.colorScheme,
    required this.l10n,
    required this.onOpenWebsite,
  });

  final VignettePurchaseEntry entry;
  final AppTextStyles textStyles;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final VoidCallback onOpenWebsite;

  @override
  Widget build(BuildContext context) {
    final vignette = entry.vignette;
    final link = entry.link;
    final notes = VignettePurchaseLocalizationService.getNotes(
      link.notesKey,
      context,
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CountryLocalizationService.getCountryName(
              vignette.countryCode,
              context,
            ),
            style: textStyles.subtitle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          CostRow(label: l10n.vignetteType, value: vignette.vignetteName),
          CostRow(label: l10n.officialProvider, value: link.providerName),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              notes,
              style: textStyles.caption.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.openOfficialWebsite,
            onPressed: onOpenWebsite,
          ),
        ],
      ),
    );
  }
}
