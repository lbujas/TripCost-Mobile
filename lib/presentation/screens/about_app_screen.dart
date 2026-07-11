import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  String? _appVersion;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) {
      return;
    }

    setState(() => _appVersion = packageInfo.version);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final versionLabel = _appVersion == null
        ? '...'
        : l10n.appVersion(_appVersion!);

    final features = [
      l10n.aboutAppFeatureFuelCost,
      l10n.aboutAppFeatureVignetteCost,
      l10n.aboutAppFeatureTollCost,
      l10n.aboutAppFeatureBackendFuelPrices,
      l10n.aboutAppFeatureBackendExchangeRates,
      l10n.aboutAppFeatureSpeedLimits,
      l10n.aboutAppFeatureVignetteLinks,
      l10n.aboutAppFeatureTripHistory,
      l10n.aboutAppFeatureMultipleVehicles,
      l10n.aboutAppFeatureResultSharing,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutApp)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.appTitle, style: textStyles.title),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  versionLabel,
                  style: textStyles.caption.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.aboutAppDescription, style: textStyles.body),
                const SizedBox(height: AppSpacing.lg),
                for (var index = 0; index < features.length; index++) ...[
                  if (index > 0) const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: textStyles.body),
                      Expanded(
                        child: Text(features[index], style: textStyles.body),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    l10n.aboutAppDisclaimer,
                    style: textStyles.body.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
