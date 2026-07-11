import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:travel_cost_planner_europe/core/utils/country_localization_service.dart';

import 'package:travel_cost_planner_europe/domain/models/route_option.dart';

import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';

import 'package:travel_cost_planner_europe/presentation/screens/car_list_screen.dart';

import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';

import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';

import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';

import 'package:travel_cost_planner_europe/presentation/widgets/async_error_view.dart';

import 'package:travel_cost_planner_europe/presentation/widgets/route_chain.dart';

import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';



/// Legacy route browser kept for compatibility.

class RouteSelectionScreen extends ConsumerWidget {

  const RouteSelectionScreen({super.key});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final l10n = AppLocalizations.of(context);

    final routesAsync = ref.watch(routesProvider);

    final textStyles = AppTextStyles.of(context);



    return Scaffold(

      appBar: AppBar(

        title: Text(l10n.selectRoute),

        actions: const [SettingsActionButton()],

      ),

      body: routesAsync.when(

        loading: () => const Center(child: CircularProgressIndicator()),

        error: (_, __) => AsyncErrorView(

          message: l10n.couldNotLoadData,

          onRetry: () => ref.invalidate(routesProvider),

        ),

        data: (routes) {

          if (routes.isEmpty) {

            return Center(

              child: Padding(

                padding: const EdgeInsets.all(AppSpacing.lg),

                child: Text(

                  l10n.noRoutesAvailable,

                  style: textStyles.body,

                  textAlign: TextAlign.center,

                ),

              ),

            );

          }



          return ListView(

            padding: const EdgeInsets.all(AppSpacing.lg),

            children: [

              Text(

                l10n.chooseYourRoute,

                style: textStyles.subtitle.copyWith(

                  color: Theme.of(context).colorScheme.onSurfaceVariant,

                ),

              ),

              const SizedBox(height: AppSpacing.sm),

              Text(

                l10n.exactDistanceDependsOnStartAndDestination,

                style: textStyles.caption.copyWith(

                  color: Theme.of(context).colorScheme.onSurfaceVariant,

                ),

              ),

              const SizedBox(height: AppSpacing.lg),

              for (var index = 0; index < routes.length; index++) ...[

                _RouteCard(

                  route: routes[index],

                  onTap: () {

                    Navigator.of(context).push(

                      MaterialPageRoute<void>(

                        builder: (context) => CarListScreen(

                          mode: CarListMode.select,

                          route: routes[index],

                        ),

                      ),

                    );

                  },

                ),

                if (index < routes.length - 1)

                  const SizedBox(height: AppSpacing.md),

              ],

            ],

          );

        },

      ),

    );

  }

}



class _RouteCard extends StatelessWidget {

  const _RouteCard({required this.route, required this.onTap});



  final RouteOption route;

  final VoidCallback onTap;



  @override

  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context);

    final colorScheme = Theme.of(context).colorScheme;

    final textStyles = AppTextStyles.of(context);



    return AppCard(

      onTap: onTap,

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Expanded(

                child: Text(

                  CountryLocalizationService.formatRouteEndpoints(

                    route.origin,

                    route.destination,

                    context,

                  ),

                  style: textStyles.title,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                ),

              ),

              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),

            ],

          ),

          const SizedBox(height: AppSpacing.md),

          RouteChain(countryCodes: route.countryCodes),

          const SizedBox(height: AppSpacing.sm),

          Text(

            l10n.routeCorridor,

            style: textStyles.caption.copyWith(

              fontWeight: FontWeight.w600,

            ),

          ),

          Text(

            l10n.distanceCalculatedLater,

            style: textStyles.caption.copyWith(

              color: colorScheme.onSurfaceVariant,

            ),

          ),

        ],

      ),

    );

  }

}


