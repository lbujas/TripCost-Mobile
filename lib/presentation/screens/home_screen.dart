import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/presentation/screens/car_list_screen.dart';
import 'package:travel_cost_planner_europe/presentation/screens/route_selection_screen.dart';
import 'package:travel_cost_planner_europe/presentation/screens/settings_screen.dart';
import 'package:travel_cost_planner_europe/presentation/screens/trip_history_screen.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/ad_banner_widget.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_button.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/popular_direction_card.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/section_title.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> _popularOriginCountryCodes = [
    'PL',
    'CZ',
    'SK',
    'HU',
    'AT',
    'SI',
    'DE',
  ];

  static double _heroHeight(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) {
      return 260;
    }
    if (width >= 600) {
      return 240;
    }
    return 190;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);
    final heroHeight = _heroHeight(context);

    return Scaffold(
      appBar: AppBar(
        actions: const [SettingsActionButton()],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          children: [
                  _HomeHeroSection(
                    height: heroHeight,
                    title: l10n.appTitle,
                    subtitle: l10n.homeSubtitle,
                    textStyles: textStyles,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: l10n.planTrip,
                    icon: Icons.travel_explore,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const CarListScreen(
                            mode: CarListMode.select,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _SecondaryHomeButton(
                    label: l10n.myCars,
                    icon: Icons.directions_car_filled_outlined,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const CarListScreen(),
                        ),
                      );
                    },
                  ),
                  _SecondaryHomeButton(
                    label: l10n.tripHistory,
                    icon: Icons.history,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const TripHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  _SecondaryHomeButton(
                    label: l10n.settings,
                    icon: Icons.settings_outlined,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SectionTitle(title: l10n.popularDirections),
                  ..._popularOriginCountryCodes.map(
                    (originCode) => PopularDirectionCard(
                      originCountryCode: originCode,
                      isActive: originCode == 'PL',
                      onTap: () => _onDirectionTap(context, originCode),
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  void _onDirectionTap(BuildContext context, String originCountryCode) {
    if (originCountryCode == 'PL') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const RouteSelectionScreen(),
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.directionComingSoon)),
    );
  }
}

class _HomeHeroSection extends StatelessWidget {
  const _HomeHeroSection({
    required this.height,
    required this.title,
    required this.subtitle,
    required this.textStyles,
  });

  final double height;
  final String title;
  final String subtitle;
  final AppTextStyles textStyles;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/hero_home.jpg',
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: textStyles.headline.copyWith(
                      color: Colors.white,
                      height: 1.15,
                      shadows: const [
                        Shadow(
                          blurRadius: 12,
                          color: Color(0x99000000),
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: textStyles.subtitle.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.25,
                      shadows: const [
                        Shadow(
                          blurRadius: 8,
                          color: Color(0x80000000),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryHomeButton extends StatelessWidget {
  const _SecondaryHomeButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }
}
