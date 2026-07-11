import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_button.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String fullPrivacyPolicyUrl =
      'https://codeluk.dev/privacy/travel-cost-planner-europe';

  Future<void> _openFullPrivacyPolicy(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri.parse(fullPrivacyPolicyUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotOpenLink)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);

    final policyPoints = [
      l10n.privacyPolicyLocalData,
      l10n.privacyPolicyNoAccount,
      l10n.privacyPolicyExchangeRates,
      l10n.privacyPolicyFuelPrices,
      l10n.privacyPolicyAdMob,
      l10n.privacyPolicyVignetteLinks,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicy)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < policyPoints.length; index++) ...[
                  if (index > 0) const SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: textStyles.body),
                      Expanded(
                        child: Text(
                          policyPoints[index],
                          style: textStyles.body,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.openFullPrivacyPolicy,
            onPressed: () => _openFullPrivacyPolicy(context),
          ),
        ],
      ),
    );
  }
}
