import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/core/utils/origin_localization_service.dart';
import 'package:travel_cost_planner_europe/domain/models/origin_city.dart';
import 'package:travel_cost_planner_europe/domain/models/polish_start_city.dart';
import 'package:travel_cost_planner_europe/domain/models/polish_voivodeship.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';

class OriginCityPickerField extends ConsumerStatefulWidget {
  const OriginCityPickerField({
    super.key,
    required this.selectedCity,
    required this.onCitySelected,
  });

  final OriginCity? selectedCity;
  final ValueChanged<OriginCity?> onCitySelected;

  @override
  ConsumerState<OriginCityPickerField> createState() =>
      _OriginCityPickerFieldState();
}

class _OriginCityPickerFieldState extends ConsumerState<OriginCityPickerField> {
  PolishVoivodeship? _selectedVoivodeship;
  PolishStartCity? _selectedPolishCity;

  String _languageCode(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  OriginCity? _findMappedOriginCity(
    String cityId,
    List<OriginCity> originCities,
  ) {
    for (final city in originCities) {
      if (city.id == cityId) {
        return city;
      }
    }
    return null;
  }

  PolishVoivodeship? _findVoivodeshipForCityId(
    String cityId,
    List<PolishVoivodeship> voivodeships,
  ) {
    for (final voivodeship in voivodeships) {
      for (final city in voivodeship.cities) {
        if (city.id == cityId) {
          return voivodeship;
        }
      }
    }
    return null;
  }

  PolishStartCity? _findPolishCity(
    String cityId,
    List<PolishVoivodeship> voivodeships,
  ) {
    for (final voivodeship in voivodeships) {
      for (final city in voivodeship.cities) {
        if (city.id == cityId) {
          return city;
        }
      }
    }
    return null;
  }

  void _syncSelectionFromOriginCity(List<PolishVoivodeship> voivodeships) {
    final selected = widget.selectedCity;
    if (selected == null || _selectedVoivodeship != null) {
      return;
    }

    final polishCity = _findPolishCity(selected.id, voivodeships);
    final voivodeship = _findVoivodeshipForCityId(selected.id, voivodeships);
    if (polishCity == null || voivodeship == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedVoivodeship = voivodeship;
        _selectedPolishCity = polishCity;
      });
    });
  }

  Future<void> _openVoivodeshipPicker(
    BuildContext context,
    List<PolishVoivodeship> voivodeships,
  ) async {
    final l10n = AppLocalizations.of(context);
    final languageCode = _languageCode(context);

    final picked = await showDialog<PolishVoivodeship>(
      context: context,
      builder: (context) {
        final textStyles = AppTextStyles.of(context);
        final sorted = [...voivodeships]
          ..sort(
            (a, b) => a.localizedName(languageCode).compareTo(
                  b.localizedName(languageCode),
                ),
          );

        return AlertDialog(
          title: Text(l10n.selectVoivodeship),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: sorted
                  .map(
                    (voivodeship) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        voivodeship.localizedName(languageCode),
                        style: textStyles.body,
                      ),
                      onTap: () => Navigator.of(context).pop(voivodeship),
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      final voivodeshipChanged = _selectedVoivodeship?.code != picked.code;
      _selectedVoivodeship = picked;
      if (voivodeshipChanged) {
        _selectedPolishCity = null;
        widget.onCitySelected(null);
      } else if (_selectedPolishCity != null &&
          !picked.cities.any((city) => city.id == _selectedPolishCity!.id)) {
        _selectedPolishCity = null;
        widget.onCitySelected(null);
      }
    });
  }

  Future<void> _openCityPicker(
    BuildContext context,
    List<OriginCity> originCities,
  ) async {
    final voivodeship = _selectedVoivodeship;
    if (voivodeship == null) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final languageCode = _languageCode(context);
    final mappableIds = originCities.map((city) => city.id).toSet();

    final picked = await showDialog<PolishStartCity>(
      context: context,
      builder: (context) {
        final textStyles = AppTextStyles.of(context);
        final colorScheme = Theme.of(context).colorScheme;
        final sorted = [...voivodeship.cities]
          ..sort(
            (a, b) => a.localizedName(languageCode).compareTo(
                  b.localizedName(languageCode),
                ),
          );

        return AlertDialog(
          title: Text(l10n.selectStartCity),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: sorted.map((city) {
                final isMappable = mappableIds.contains(city.id);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: isMappable,
                  title: Text(
                    city.localizedName(languageCode),
                    style: textStyles.body.copyWith(
                      color: isMappable
                          ? null
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  subtitle: isMappable
                      ? null
                      : Text(
                          l10n.originCityNotAvailableYet,
                          style: textStyles.caption.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                  onTap: isMappable
                      ? () => Navigator.of(context).pop(city)
                      : null,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );

    if (picked == null || !mounted) {
      return;
    }

    final mapped = _findMappedOriginCity(picked.id, originCities);
    if (mapped == null) {
      return;
    }

    setState(() => _selectedPolishCity = picked);
    widget.onCitySelected(mapped);
  }

  Widget _buildSelectorField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback? onTap,
    required bool isPlaceholder,
  }) {
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(icon),
          enabled: onTap != null,
        ),
        child: Text(
          value,
          style: textStyles.body.copyWith(
            color: isPlaceholder
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = _languageCode(context);
    final voivodeshipsAsync = ref.watch(polishVoivodeshipsProvider);
    final originCitiesAsync = ref.watch(originCitiesProvider);

    return voivodeshipsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: LinearProgressIndicator(),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _buildSelectorField(
          context: context,
          label: l10n.voivodeship,
          value: l10n.couldNotLoadData,
          icon: Icons.map_outlined,
          onTap: null,
          isPlaceholder: true,
        ),
      ),
      data: (voivodeships) {
        _syncSelectionFromOriginCity(voivodeships);

        final voivodeshipLabel = _selectedVoivodeship == null
            ? l10n.selectVoivodeship
            : _selectedVoivodeship!.localizedName(languageCode);

        final cityLabel = widget.selectedCity == null
            ? l10n.selectStartCity
            : (_selectedPolishCity?.localizedName(languageCode) ??
                OriginLocalizationService.getOriginCityName(
                  widget.selectedCity!.id,
                  context,
                  fallbackName: widget.selectedCity!.name,
                ));

        final originCities = originCitiesAsync.maybeWhen(
          data: (value) => value,
          orElse: () => const <OriginCity>[],
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            children: [
              _buildSelectorField(
                context: context,
                label: l10n.voivodeship,
                value: voivodeshipLabel,
                icon: Icons.map_outlined,
                onTap: () => _openVoivodeshipPicker(context, voivodeships),
                isPlaceholder: _selectedVoivodeship == null,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildSelectorField(
                context: context,
                label: l10n.startCity,
                value: cityLabel,
                icon: Icons.location_city_outlined,
                onTap: _selectedVoivodeship == null
                    ? null
                    : () => _openCityPicker(context, originCities),
                isPlaceholder: widget.selectedCity == null,
              ),
            ],
          ),
        );
      },
    );
  }
}
