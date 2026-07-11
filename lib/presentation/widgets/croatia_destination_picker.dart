import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/core/utils/croatia_localization_service.dart';
import 'package:travel_cost_planner_europe/core/utils/string_search_utils.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_destination.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/cost_row.dart';

const _regionOrder = [
  'istria',
  'kvarner',
  'zadar',
  'sibenik',
  'split',
  'makarska',
  'ploce',
  'dubrovnik',
];

const _maxPopularDestinations = 6;
const _regionTileExtent = 120.0;

class CroatiaDestinationPickerField extends ConsumerWidget {
  const CroatiaDestinationPickerField({
    super.key,
    required this.selectedDestination,
    required this.onDestinationSelected,
  });

  final CroatiaDestination? selectedDestination;
  final ValueChanged<CroatiaDestination> onDestinationSelected;

  Future<void> _openPicker(BuildContext context, WidgetRef ref) async {
    final destination = await showDialog<CroatiaDestination>(
      context: context,
      builder: (context) => const _CroatiaDestinationPickerDialog(),
    );

    if (destination != null) {
      await ref
          .read(croatiaDestinationRepositoryProvider)
          .addRecentDestination(destination.id);
      onDestinationSelected(destination);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final label = selectedDestination == null
        ? l10n.noDestinationSelected
        : CroatiaLocalizationService.getDestinationName(
            selectedDestination!.id,
            context,
            fallbackName: selectedDestination!.name,
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () => _openPicker(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: l10n.croatiaDestination,
            suffixIcon: const Icon(Icons.search),
          ),
          child: Text(
            label,
            style: textStyles.body.copyWith(
              color: selectedDestination == null
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class SelectedCroatiaDestinationCard extends ConsumerWidget {
  const SelectedCroatiaDestinationCard({
    super.key,
    required this.destination,
  });

  final CroatiaDestination destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final repository = ref.watch(croatiaDestinationRepositoryProvider);

    final destinationName = CroatiaLocalizationService.getDestinationName(
      destination.id,
      context,
      fallbackName: destination.name,
    );
    final regionName = CroatiaLocalizationService.getRegionName(
      destination.regionId,
      context,
    );

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.place_outlined,
                color: colorScheme.secondary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.selectedDestination,
                      style: textStyles.caption.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(destinationName, style: textStyles.title),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          CostRow(label: l10n.regionLabel, value: regionName),
          CostRow(
            label: l10n.extraDistance,
            value: '+${destination.extraDistanceKm.toStringAsFixed(0)} km',
          ),
          FutureBuilder(
            future: repository.getTollForDestination(destination),
            builder: (context, snapshot) {
              final tollDestination = snapshot.data?.destination;
              if (tollDestination == null) {
                return const SizedBox.shrink();
              }

              return CostRow(
                label: l10n.tollDestination,
                value: tollDestination,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CroatiaDestinationPickerDialog extends ConsumerStatefulWidget {
  const _CroatiaDestinationPickerDialog();

  @override
  ConsumerState<_CroatiaDestinationPickerDialog> createState() =>
      _CroatiaDestinationPickerDialogState();
}

class _CroatiaDestinationPickerDialogState
    extends ConsumerState<_CroatiaDestinationPickerDialog> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _selectedRegionId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _destinationName(CroatiaDestination destination) {
    return CroatiaLocalizationService.getDestinationName(
      destination.id,
      context,
      fallbackName: destination.name,
    );
  }

  void _sortDestinationsAlphabetically(List<CroatiaDestination> destinations) {
    destinations.sort(
      (a, b) => _destinationName(a).toLowerCase().compareTo(
            _destinationName(b).toLowerCase(),
          ),
    );
  }

  List<CroatiaDestination> _filterDestinations(
    List<CroatiaDestination> destinations,
    String query,
  ) {
    if (query.isEmpty) {
      return destinations;
    }

    return destinations.where((destination) {
      final localized = _destinationName(destination);
      return StringSearchUtils.matchesQuery(localized, query) ||
          StringSearchUtils.matchesQuery(destination.name, query);
    }).toList();
  }

  String _regionTitle(AppLocalizations l10n, String regionId) {
    return switch (regionId) {
      'istria' => l10n.istria,
      'kvarner' => l10n.kvarner,
      'zadar' => l10n.zadarRegion,
      'sibenik' => l10n.sibenikRegion,
      'split' => l10n.splitRegion,
      'makarska' => l10n.makarskaRiviera,
      'ploce' => l10n.ploceRegion,
      'dubrovnik' => l10n.dubrovnikRegion,
      _ => regionId,
    };
  }

  String _regionEmoji(String regionId) {
    return switch (regionId) {
      'istria' => '🏖',
      'kvarner' => '🌊',
      'zadar' => '🏝',
      'sibenik' => '⛵',
      'split' => '🏛',
      'makarska' => '🌅',
      'ploce' => '🚢',
      'dubrovnik' => '🏰',
      _ => '',
    };
  }

  int _gridColumnCount(double width) {
    if (width > 800) {
      return 4;
    }
    if (width >= 500) {
      return 3;
    }
    return 2;
  }

  Map<String, int> _destinationCountByRegion(
    List<CroatiaDestination> destinations,
  ) {
    final counts = <String, int>{};
    for (final destination in destinations) {
      counts[destination.regionId] = (counts[destination.regionId] ?? 0) + 1;
    }
    return counts;
  }

  void _selectRegion(String regionId) {
    setState(() => _selectedRegionId = regionId);
  }

  void _backToAllRegions() {
    setState(() => _selectedRegionId = null);
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
      if (value.isNotEmpty) {
        _selectedRegionId = null;
      }
    });
  }

  List<Widget> _buildSearchResultTiles(
    List<CroatiaDestination> destinations,
    AppLocalizations l10n,
    AppTextStyles textStyles,
  ) {
    final filtered = _filterDestinations(destinations, _query);
    _sortDestinationsAlphabetically(filtered);

    if (filtered.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Text(
            l10n.noDestinationsFound,
            style: textStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }

    return filtered
        .map(
          (destination) => _DestinationTile(
            destination: destination,
            showRegion: true,
            onTap: () => Navigator.of(context).pop(destination),
          ),
        )
        .toList();
  }

  List<Widget> _buildRegionDetailTiles(
    List<CroatiaDestination> destinations,
    AppLocalizations l10n,
    AppTextStyles textStyles,
  ) {
    final regionId = _selectedRegionId!;
    final inRegion = destinations
        .where((destination) => destination.regionId == regionId)
        .toList();
    _sortDestinationsAlphabetically(inRegion);

    return [
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _backToAllRegions,
          icon: const Icon(Icons.arrow_back),
          label: Text(l10n.backToRegions),
        ),
      ),
      Text(
        '${_regionEmoji(regionId)} ${_regionTitle(l10n, regionId)}',
        style: textStyles.subtitle.copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: AppSpacing.md),
      ...inRegion.map(
        (destination) => _DestinationTile(
          destination: destination,
          showRegion: false,
          onTap: () => Navigator.of(context).pop(destination),
        ),
      ),
    ];
  }

  List<Widget> _buildRegionGridTiles(
    List<CroatiaDestination> destinations,
    AppLocalizations l10n,
    AppTextStyles textStyles,
    ColorScheme colorScheme,
    double maxWidth,
  ) {
    final counts = _destinationCountByRegion(destinations);
    final columnCount = _gridColumnCount(maxWidth);

    final popular = destinations.where((d) => d.popular).toList();
    _sortDestinationsAlphabetically(popular);
    final topPopular = popular.take(_maxPopularDestinations).toList();

    return [
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisExtent: _regionTileExtent,
        ),
        itemCount: _regionOrder.length,
        itemBuilder: (context, index) {
          final regionId = _regionOrder[index];
          final count = counts[regionId] ?? 0;

          return _RegionTile(
            emoji: _regionEmoji(regionId),
            title: _regionTitle(l10n, regionId),
            countLabel: l10n.destinationsCount(count),
            onTap: () => _selectRegion(regionId),
          );
        },
      ),
      if (topPopular.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.popularDestinations,
          style: textStyles.subtitle.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...topPopular.map(
          (destination) => _DestinationTile(
            destination: destination,
            showRegion: true,
            onTap: () => Navigator.of(context).pop(destination),
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildScrollChildren(
    List<CroatiaDestination> destinations,
    AppLocalizations l10n,
    AppTextStyles textStyles,
    ColorScheme colorScheme,
    double maxWidth,
  ) {
    if (_query.isNotEmpty) {
      return _buildSearchResultTiles(destinations, l10n, textStyles);
    }

    if (_selectedRegionId != null) {
      return _buildRegionDetailTiles(destinations, l10n, textStyles);
    }

    return _buildRegionGridTiles(
      destinations,
      l10n,
      textStyles,
      colorScheme,
      maxWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final destinationsAsync = ref.watch(croatiaDestinationsProvider);

    return AlertDialog(
      title: Text(l10n.selectCroatiaDestination),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.sizeOf(context).height * 0.65,
        child: destinationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.couldNotLoadData, style: textStyles.body),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => ref.invalidate(croatiaDestinationsProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
          data: (destinations) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: l10n.searchDestinations,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.chooseTownOrClosestDestination,
                    style: textStyles.caption.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ListView(
                        children: _buildScrollChildren(
                          destinations,
                          l10n,
                          textStyles,
                          colorScheme,
                          constraints.maxWidth,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}

class _RegionTile extends StatelessWidget {
  const _RegionTile({
    required this.emoji,
    required this.title,
    required this.countLabel,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String countLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox.expand(
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 26, height: 1.1),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Flexible(
            child: Text(
              title,
              style: textStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            countLabel,
            style: textStyles.caption.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        ),
      ),
    );
  }
}

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({
    required this.destination,
    required this.onTap,
    this.showRegion = true,
  });

  final CroatiaDestination destination;
  final VoidCallback onTap;
  final bool showRegion;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        CroatiaLocalizationService.getDestinationName(
          destination.id,
          context,
          fallbackName: destination.name,
        ),
        style: textStyles.body,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: showRegion
          ? Text(
              CroatiaLocalizationService.getRegionName(
                destination.regionId,
                context,
              ),
              style: textStyles.caption.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Text(
        '+${destination.extraDistanceKm.toStringAsFixed(0)} km',
        style: textStyles.caption.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: onTap,
    );
  }
}
