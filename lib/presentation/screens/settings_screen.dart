import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:travel_cost_planner_europe/core/utils/app_support_launch_utils.dart';
import 'package:travel_cost_planner_europe/domain/models/app_settings.dart';
import 'package:travel_cost_planner_europe/domain/models/app_statistics.dart';
import 'package:travel_cost_planner_europe/domain/models/currency_rates.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_button.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/cost_row.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/ad_banner_widget.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_text_field.dart';
import 'package:travel_cost_planner_europe/presentation/screens/about_app_screen.dart';
import 'package:travel_cost_planner_europe/presentation/screens/privacy_policy_screen.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/section_title.dart';

enum AppLanguageOption {
  system,
  polish,
  english,
  german,
  croatian,
  czech,
  slovak,
  hungarian,
}

enum AppPreferredCurrencyOption {
  auto,
  eur,
  pln,
  czk,
  huf,
}

extension AppPreferredCurrencyOptionX on AppPreferredCurrencyOption {
  String get currencyCode {
    return switch (this) {
      AppPreferredCurrencyOption.auto => 'auto',
      AppPreferredCurrencyOption.eur => 'EUR',
      AppPreferredCurrencyOption.pln => 'PLN',
      AppPreferredCurrencyOption.czk => 'CZK',
      AppPreferredCurrencyOption.huf => 'HUF',
    };
  }

  static AppPreferredCurrencyOption fromCurrencyCode(String code) {
    return switch (code) {
      'EUR' => AppPreferredCurrencyOption.eur,
      'PLN' => AppPreferredCurrencyOption.pln,
      'CZK' => AppPreferredCurrencyOption.czk,
      'HUF' => AppPreferredCurrencyOption.huf,
      _ => AppPreferredCurrencyOption.auto,
    };
  }
}

extension AppLanguageOptionX on AppLanguageOption {
  String get languageCode {
    return switch (this) {
      AppLanguageOption.system => 'system',
      AppLanguageOption.polish => 'pl',
      AppLanguageOption.english => 'en',
      AppLanguageOption.german => 'de',
      AppLanguageOption.croatian => 'hr',
      AppLanguageOption.czech => 'cs',
      AppLanguageOption.slovak => 'sk',
      AppLanguageOption.hungarian => 'hu',
    };
  }

  static AppLanguageOption fromLanguageCode(String code) {
    return switch (code) {
      'pl' => AppLanguageOption.polish,
      'en' => AppLanguageOption.english,
      'de' => AppLanguageOption.german,
      'hr' => AppLanguageOption.croatian,
      'cs' => AppLanguageOption.czech,
      'sk' => AppLanguageOption.slovak,
      'hu' => AppLanguageOption.hungarian,
      _ => AppLanguageOption.system,
    };
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _peopleCountController = TextEditingController();
  final _tripDaysController = TextEditingController();

  AppThemeMode _themeMode = AppThemeMode.system;
  AppLanguageOption _languageOption = AppLanguageOption.system;
  AppPreferredCurrencyOption _currencyOption = AppPreferredCurrencyOption.auto;
  bool _initialized = false;
  bool _isSaving = false;
  CurrencyRates? _displayRates;
  bool _displayRatesLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDisplayRates();
    });
  }

  Future<void> _loadDisplayRates() async {
    setState(() => _displayRatesLoading = true);

    try {
      final rates = await ref
          .read(currencyRatesRepositoryProvider)
          .getCurrencyRates(forceRemote: true);
      if (!mounted) {
        return;
      }

      setState(() {
        _displayRates = rates;
        _displayRatesLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _displayRatesLoading = false);
    }
  }

  @override
  void dispose() {
    _peopleCountController.dispose();
    _tripDaysController.dispose();
    super.dispose();
  }

  void _applySettings(AppSettings settings) {
    _themeMode = settings.themeMode;
    _languageOption =
        AppLanguageOptionX.fromLanguageCode(settings.languageCode);
    _currencyOption = AppPreferredCurrencyOptionX.fromCurrencyCode(
      settings.preferredCurrency,
    );
    _peopleCountController.text = settings.defaultPeopleCount.toString();
    _tripDaysController.text = settings.defaultTripDays.toString();
    _initialized = true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _languageLabel(AppLanguageOption option, AppLocalizations l10n) {
    return switch (option) {
      AppLanguageOption.system => '🌐 ${l10n.languageSystem}',
      AppLanguageOption.polish => '🇵🇱 ${l10n.languagePolish}',
      AppLanguageOption.english => '🇬🇧 ${l10n.languageEnglish}',
      AppLanguageOption.german => '🇩🇪 ${l10n.languageGerman}',
      AppLanguageOption.croatian => '🇭🇷 ${l10n.languageCroatian}',
      AppLanguageOption.czech => '🇨🇿 ${l10n.languageCzech}',
      AppLanguageOption.slovak => '🇸🇰 ${l10n.languageSlovak}',
      AppLanguageOption.hungarian => '🇭🇺 ${l10n.languageHungarian}',
    };
  }

  String _currencyLabel(AppPreferredCurrencyOption option, AppLocalizations l10n) {
    return switch (option) {
      AppPreferredCurrencyOption.auto => '⚙️ ${l10n.autoCurrency}',
      AppPreferredCurrencyOption.eur => '💶 EUR',
      AppPreferredCurrencyOption.pln => '🇵🇱 PLN',
      AppPreferredCurrencyOption.czk => '🇨🇿 CZK',
      AppPreferredCurrencyOption.huf => '🇭🇺 HUF',
    };
  }

  String _formatExchangeRateValue(double rate, String currencyCode) {
    if (currencyCode == 'HUF') {
      return _trimTrailingZeros(rate.toStringAsFixed(2));
    }
    return _trimTrailingZeros(rate.toStringAsFixed(3));
  }

  String _trimTrailingZeros(String value) {
    if (!value.contains('.')) {
      return value;
    }
    return value
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  double? _lookupRate(CurrencyRates rates, String currencyCode) {
    final normalized = currencyCode.toUpperCase();
    for (final entry in rates.rates.entries) {
      if (entry.key.toUpperCase() == normalized) {
        return entry.value;
      }
    }
    return null;
  }

  bool _hasDisplayRates(CurrencyRates rates) {
    const currencies = ['PLN', 'CZK', 'HUF'];
    return currencies.every((code) => _lookupRate(rates, code) != null);
  }

  CurrencyRates? _resolveDisplayRates(AsyncValue<CurrencyRates> ratesAsync) {
    final displayRates = _displayRates;
    if (displayRates != null && _hasDisplayRates(displayRates)) {
      return displayRates;
    }

    final providerRates = ratesAsync.asData?.value;
    if (providerRates != null && _hasDisplayRates(providerRates)) {
      return providerRates;
    }

    return null;
  }

  bool _isExchangeRatesLoading(AsyncValue<CurrencyRates> ratesAsync) {
    return _displayRatesLoading || ratesAsync.isLoading;
  }

  Widget _buildExchangeRatesContent(
    AppLocalizations l10n,
    AppTextStyles textStyles,
    ColorScheme colorScheme,
    CurrencyRates rates,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.currency_exchange,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.exchangeRates,
                style: textStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final currency in ['PLN', 'CZK', 'HUF']) ...[
            Text(
              l10n.exchangeRateEurToCurrency(
                _formatExchangeRateValue(
                  _lookupRate(rates, currency)!,
                  currency,
                ),
                currency,
              ),
              style: textStyles.body,
            ),
            if (currency != 'HUF') const SizedBox(height: AppSpacing.xs),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.exchangeRatesUpdatedDaily,
            style: textStyles.caption.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (rates.updatedAt.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.exchangeRatesLastUpdate(rates.updatedAt),
              style: textStyles.caption.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExchangeRatesCard(
    AppLocalizations l10n,
    AppTextStyles textStyles,
    ColorScheme colorScheme,
    AsyncValue<CurrencyRates> ratesAsync,
  ) {
    final displayRates = _resolveDisplayRates(ratesAsync);
    if (displayRates != null) {
      return _buildExchangeRatesContent(
        l10n,
        textStyles,
        colorScheme,
        displayRates,
      );
    }

    if (_isExchangeRatesLoading(ratesAsync)) {
      return AppCard(
        child: Row(
          children: [
            Icon(
              Icons.sync_alt,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                l10n.exchangeRatesLoading,
                style: textStyles.caption.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.currency_exchange,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              l10n.exchangeRatesUnavailable,
              style: textStyles.caption.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openRateApp() async {
    final l10n = AppLocalizations.of(context);
    final launched = await AppSupportLaunchUtils.launchGooglePlayListing();
    if (!launched && mounted) {
      _showError(l10n.couldNotOpenLink);
    }
  }

  Future<void> _openContact() async {
    final l10n = AppLocalizations.of(context);
    final launched = await AppSupportLaunchUtils.launchContactEmail(
      subject: l10n.contactEmailSubject,
    );
    if (!launched && mounted) {
      _showError(l10n.couldNotOpenLink);
    }
  }

  Widget _buildSettingsLabelRow({
    required IconData icon,
    required String label,
    required AppTextStyles textStyles,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(label, style: textStyles.body),
        ),
      ],
    );
  }

  Widget _buildAboutLegalListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      leading: Icon(
        icon,
        size: 22,
        color: colorScheme.primary,
      ),
      title: Text(title, style: textStyles.body),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  Widget _buildAboutLegalDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final peopleCount = int.tryParse(_peopleCountController.text.trim());
    final tripDays = int.tryParse(_tripDaysController.text.trim());

    if (peopleCount == null || tripDays == null) {
      _showError(l10n.errorInvalidNumbers);
      return;
    }

    if (peopleCount < 1) {
      _showError(l10n.errorPeopleMin);
      return;
    }

    if (tripDays < 1) {
      _showError(l10n.errorTripDaysMin);
      return;
    }

    setState(() => _isSaving = true);

    final currentSettings = ref.read(appSettingsProvider).maybeWhen(
          data: (settings) => settings,
          orElse: () => AppSettings.defaults(),
        );

    final settings = currentSettings.copyWith(
      themeMode: _themeMode,
      languageCode: _languageOption.languageCode,
      preferredCurrency: _currencyOption.currencyCode,
      defaultPeopleCount: peopleCount,
      defaultTripDays: tripDays,
    );

    try {
      await ref.read(settingsRepositoryProvider).saveSettings(settings);
      ref.invalidate(appSettingsProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsSaved)),
      );
    } catch (_) {
      if (mounted) {
        _showError(l10n.couldNotSaveSettings);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildSettingsContent(
    AppLocalizations l10n,
    AppTextStyles textStyles,
    AsyncValue<AppStatistics> statisticsAsync,
    AsyncValue<CurrencyRates> ratesAsync, {
    bool showSettingsLoadWarning = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (showSettingsLoadWarning) ...[
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.couldNotLoadSettings,
                    style: textStyles.body,
                  ),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(appSettingsProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        SectionTitle(
          title: l10n.appearance,
          subtitle: l10n.appearanceSubtitle,
          icon: Icons.palette_outlined,
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingsLabelRow(
                icon: Icons.dark_mode_outlined,
                label: l10n.themeMode,
                textStyles: textStyles,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: AppSpacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<AppThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: AppThemeMode.system,
                      label: Text(l10n.themeSystem),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.light,
                      label: Text(l10n.themeLight),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.dark,
                      label: Text(l10n.themeDark),
                    ),
                  ],
                  selected: {_themeMode},
                  onSelectionChanged: (selected) {
                    setState(() => _themeMode = selected.first);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionTitle(
          title: l10n.language,
          subtitle: l10n.languageSubtitle,
          icon: Icons.language,
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingsLabelRow(
                icon: Icons.language,
                label: l10n.language,
                textStyles: textStyles,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: AppLanguageOption.values.map((option) {
                  return FilterChip(
                    avatar: option == AppLanguageOption.system
                        ? Icon(
                            Icons.public,
                            size: 18,
                            color: colorScheme.primary,
                          )
                        : null,
                    label: Text(_languageLabel(option, l10n)),
                    selected: _languageOption == option,
                    onSelected: (_) {
                      setState(() => _languageOption = option);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionTitle(
          title: l10n.currency,
          subtitle: l10n.preferredCurrency,
          icon: Icons.currency_exchange,
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingsLabelRow(
                icon: Icons.currency_exchange,
                label: l10n.displayCurrency,
                textStyles: textStyles,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: AppPreferredCurrencyOption.values.map((option) {
                  return FilterChip(
                    label: Text(_currencyLabel(option, l10n)),
                    selected: _currencyOption == option,
                    onSelected: (_) {
                      setState(() => _currencyOption = option);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildExchangeRatesCard(l10n, textStyles, colorScheme, ratesAsync),
        const SizedBox(height: AppSpacing.xl),
        SectionTitle(
          title: l10n.tripDefaults,
          subtitle: l10n.tripDefaultsSubtitle,
          icon: Icons.tune_outlined,
        ),
        AppTextField(
          controller: _peopleCountController,
          label: l10n.defaultPeopleCount,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          prefixIcon: Icons.groups_outlined,
        ),
        AppTextField(
          controller: _tripDaysController,
          label: l10n.defaultTripDays,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          prefixIcon: Icons.calendar_month_outlined,
        ),
        AppButton(
          label: l10n.save,
          isLoading: _isSaving,
          onPressed: _isSaving ? null : _save,
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionTitle(
          title: l10n.appStatistics,
          subtitle: l10n.appStatisticsSubtitle,
          icon: Icons.bar_chart_outlined,
        ),
        statisticsAsync.when(
          loading: () => const AppCard(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.couldNotLoadStatistics,
                  style: textStyles.body,
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => ref.invalidate(statisticsProvider),
                    child: Text(l10n.retry),
                  ),
                ),
              ],
            ),
          ),
          data: (statistics) => AppCard(
            child: Column(
              children: [
                CostRow(
                  label: l10n.calculationsPerformed,
                  value: statistics.calculationsCount.toString(),
                  icon: Icons.calculate_outlined,
                ),
                CostRow(
                  label: l10n.tripsSaved,
                  value: statistics.savedTripsCount.toString(),
                  icon: Icons.bookmark_added_outlined,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionTitle(
          title: l10n.aboutAndLegal,
          subtitle: l10n.aboutAndLegalSubtitle,
          icon: Icons.info_outline,
        ),
        AppCard(
          child: Column(
            children: [
              _buildAboutLegalListTile(
                title: l10n.aboutApp,
                icon: Icons.info_outline,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const AboutAppScreen(),
                    ),
                  );
                },
              ),
              _buildAboutLegalDivider(),
              _buildAboutLegalListTile(
                title: l10n.privacyPolicy,
                icon: Icons.privacy_tip_outlined,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
              _buildAboutLegalDivider(),
              _buildAboutLegalListTile(
                title: l10n.contact,
                icon: Icons.mail_outline,
                onTap: _openContact,
              ),
              _buildAboutLegalDivider(),
              _buildAboutLegalListTile(
                title: l10n.rateApp,
                icon: Icons.star_rate_outlined,
                onTap: _openRateApp,
              ),
              _buildAboutLegalDivider(),
              _buildAboutLegalListTile(
                title: l10n.openSourceLicenses,
                icon: Icons.code_outlined,
                onTap: () async {
                  final packageInfo = await PackageInfo.fromPlatform();
                  if (!mounted) {
                    return;
                  }

                  showLicensePage(
                    context: context,
                    applicationName: l10n.appTitle,
                    applicationVersion: packageInfo.version,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final statisticsAsync = ref.watch(statisticsProvider);
    final ratesAsync = ref.watch(currencyRatesProvider);
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Column(
        children: [
          Expanded(
            child: settingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) {
                if (!_initialized) {
                  _applySettings(AppSettings.defaults());
                }

                return _buildSettingsContent(
                  l10n,
                  textStyles,
                  statisticsAsync,
                  ratesAsync,
                  showSettingsLoadWarning: true,
                );
              },
              data: (settings) {
                if (!_initialized) {
                  _applySettings(settings);
                }

                return _buildSettingsContent(
                  l10n,
                  textStyles,
                  statisticsAsync,
                  ratesAsync,
                );
              },
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }
}
