import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/presentation/screens/home_screen.dart';
import 'package:travel_cost_planner_europe/presentation/screens/settings_screen.dart';

class SettingsActionButton extends StatelessWidget {
  const SettingsActionButton({super.key});

  static void openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  static void openHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (context) => const HomeScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => openHome(context),
          icon: const Icon(Icons.home_outlined),
          tooltip: 'TripCost',
        ),
        IconButton(
          onPressed: () => openSettings(context),
          icon: const Icon(Icons.settings_outlined),
          tooltip: l10n.settings,
        ),
      ],
    );
  }
}