import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:travel_cost_planner_europe/domain/models/app_settings.dart';

import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';

import 'package:travel_cost_planner_europe/presentation/screens/home_screen.dart';

import 'package:travel_cost_planner_europe/presentation/theme/app_theme.dart';



class TravelCostPlannerApp extends ConsumerWidget {

  const TravelCostPlannerApp({super.key});



  static const supportedLocales = [

    Locale('pl'),

    Locale('en'),

    Locale('de'),

    Locale('hr'),

    Locale('cs'),

    Locale('sk'),

    Locale('hu'),

  ];



  Locale? _resolveLocale(AppSettings settings) {

    if (settings.languageCode == 'system') {

      return null;

    }



    return Locale(settings.languageCode);

  }



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final settingsAsync = ref.watch(appSettingsProvider);



    final settings = settingsAsync.maybeWhen(

      data: (value) => value,

      orElse: () => AppSettings.defaults(),

    );



    final themeMode = settings.themeMode.toThemeMode();

    final locale = _resolveLocale(settings);



    return MaterialApp(

      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,

      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.darkTheme,

      themeMode: themeMode,

      locale: locale,

      localizationsDelegates: const [

        AppLocalizations.delegate,

        GlobalMaterialLocalizations.delegate,

        GlobalWidgetsLocalizations.delegate,

        GlobalCupertinoLocalizations.delegate,

      ],

      supportedLocales: supportedLocales,

      localeResolutionCallback: (deviceLocale, _) {

        if (deviceLocale == null) {

          return const Locale('en');

        }



        for (final supportedLocale in supportedLocales) {

          if (supportedLocale.languageCode == deviceLocale.languageCode) {

            return supportedLocale;

          }

        }



        return const Locale('en');

      },

      home: const HomeScreen(),

    );

  }

}


