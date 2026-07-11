import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:travel_cost_planner_europe/app.dart';
import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/core/constants/demo_car.dart';
import 'package:travel_cost_planner_europe/domain/models/app_settings.dart';
import 'package:travel_cost_planner_europe/domain/services/ad_service.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HiveService hiveService;

  setUpAll(() async {
    Hive.init('./test/.hive_widget');
    hiveService = await HiveService.open();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  Future<void> pumpEnglishApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hiveServiceProvider.overrideWithValue(hiveService),
          adServiceProvider.overrideWithValue(AdService()),
          appSettingsProvider.overrideWith(
            (ref) async => AppSettings.defaults().copyWith(languageCode: 'en'),
          ),
          carsProvider.overrideWith((ref) async => [DemoCar.value]),
          savedTripsProvider.overrideWith((ref) async => []),
        ],
        child: const TravelCostPlannerApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('Home loads main actions', (tester) async {
    await pumpEnglishApp(tester);

    expect(find.text('Plan trip'), findsOneWidget);
    expect(find.text('My cars'), findsOneWidget);
    expect(find.text('Trip history'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Settings opens from home', (tester) async {
    await pumpEnglishApp(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.settings_outlined),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Appearance'), findsOneWidget);
  });

  testWidgets('Settings shows rate and contact rows', (tester) async {
    await pumpEnglishApp(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.settings_outlined),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(
      find.text('Rate app'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Rate app'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
  });

  testWidgets('Trip history opens from home', (tester) async {
    await pumpEnglishApp(tester);

    await tester.tap(find.text('Trip history'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Trip history'), findsWidgets);
    expect(find.text('No saved trips yet'), findsOneWidget);
  });

  testWidgets('Car list opens from home', (tester) async {
    await pumpEnglishApp(tester);

    await tester.tap(find.text('My cars'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('My cars'), findsWidgets);
    expect(find.text('Renault Megane 1.0 TCe'), findsOneWidget);
  });
}
