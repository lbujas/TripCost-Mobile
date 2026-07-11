import 'package:flutter/material.dart';

enum AppThemeMode {
  system,
  light,
  dark;

  static AppThemeMode fromJson(String value) {
    return switch (value) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      _ => AppThemeMode.system,
    };
  }

  String toJson() => name;

  ThemeMode toThemeMode() {
    return switch (this) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };
  }
}

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.languageCode,
    required this.preferredCurrency,
    required this.defaultFuelPricePln,
    required this.defaultEurToPln,
    required this.defaultPeopleCount,
    required this.defaultTripDays,
  });

  static const Set<String> allowedLanguageCodes = {
    'system',
    'pl',
    'en',
    'de',
    'hr',
    'cs',
    'sk',
    'hu',
  };

  static const Set<String> allowedPreferredCurrencies = {
    'auto',
    'EUR',
    'PLN',
    'CZK',
    'HUF',
  };

  final AppThemeMode themeMode;
  final String languageCode;
  final String preferredCurrency;
  final double defaultFuelPricePln;
  final double defaultEurToPln;
  final int defaultPeopleCount;
  final int defaultTripDays;

  factory AppSettings.defaults() {
    return const AppSettings(
      themeMode: AppThemeMode.system,
      languageCode: 'system',
      preferredCurrency: 'auto',
      defaultFuelPricePln: 6.00,
      defaultEurToPln: 4.30,
      defaultPeopleCount: 3,
      defaultTripDays: 16,
    );
  }

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? languageCode,
    String? preferredCurrency,
    double? defaultFuelPricePln,
    double? defaultEurToPln,
    int? defaultPeopleCount,
    int? defaultTripDays,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      defaultFuelPricePln: defaultFuelPricePln ?? this.defaultFuelPricePln,
      defaultEurToPln: defaultEurToPln ?? this.defaultEurToPln,
      defaultPeopleCount: defaultPeopleCount ?? this.defaultPeopleCount,
      defaultTripDays: defaultTripDays ?? this.defaultTripDays,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final languageCode = json['languageCode'] as String? ?? 'system';
    final preferredCurrency = json['preferredCurrency'] as String? ?? 'auto';
    return AppSettings(
      themeMode: AppThemeMode.fromJson(json['themeMode'] as String? ?? 'system'),
      languageCode: allowedLanguageCodes.contains(languageCode)
          ? languageCode
          : 'system',
      preferredCurrency: allowedPreferredCurrencies.contains(preferredCurrency)
          ? preferredCurrency
          : 'auto',
      defaultFuelPricePln:
          (json['defaultFuelPricePln'] as num?)?.toDouble() ?? 6.00,
      defaultEurToPln: (json['defaultEurToPln'] as num?)?.toDouble() ?? 4.30,
      defaultPeopleCount: json['defaultPeopleCount'] as int? ?? 3,
      defaultTripDays: json['defaultTripDays'] as int? ?? 16,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.toJson(),
      'languageCode': languageCode,
      'preferredCurrency': preferredCurrency,
      'defaultFuelPricePln': defaultFuelPricePln,
      'defaultEurToPln': defaultEurToPln,
      'defaultPeopleCount': defaultPeopleCount,
      'defaultTripDays': defaultTripDays,
    };
  }
}
