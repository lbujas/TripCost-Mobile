import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:travel_cost_planner_europe/app.dart';
import 'package:travel_cost_planner_europe/core/constants/demo_car.dart';
import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/domain/models/app_settings.dart';
import 'package:travel_cost_planner_europe/domain/services/ad_service.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/create_packing_list_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_list_creation_method_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_lists_screen.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';

import '../../fake_packing_list_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePackingListRepository repository;
  late HiveService hiveService;

  setUpAll(() async {
    Hive.init('./test/.hive_packing_widget');
    hiveService = await HiveService.open();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  setUp(() {
    repository = FakePackingListRepository();
  });

  Widget buildTestApp(Widget child) {
    return ProviderScope(
      overrides: [
        adServiceProvider.overrideWithValue(AdService()),
        appSettingsProvider.overrideWith(
          (ref) async => AppSettings.defaults().copyWith(languageCode: 'en'),
        ),
        carsProvider.overrideWith((ref) async => [DemoCar.value]),
        savedTripsProvider.overrideWith((ref) async => []),
        packingListRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: TravelCostPlannerApp.supportedLocales,
        home: child,
      ),
    );
  }

  Future<void> pumpHome(WidgetTester tester) async {
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
          packingListRepositoryProvider.overrideWithValue(repository),
        ],
        child: const TravelCostPlannerApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('Home shows Packing Lists button', (tester) async {
    await pumpHome(tester);

    expect(find.text('Packing Lists'), findsOneWidget);
  });

  testWidgets('tapping Home button opens PackingListsScreen', (tester) async {
    await pumpHome(tester);

    await tester.scrollUntilVisible(
      find.text('Packing Lists'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    await tester.tap(find.text('Packing Lists'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(PackingListsScreen), findsOneWidget);
    expect(find.text('No packing lists yet'), findsOneWidget);
  });

  testWidgets('empty state is shown', (tester) async {
    await tester.pumpWidget(buildTestApp(const PackingListsScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No packing lists yet'), findsOneWidget);
    expect(find.text('Create your first packing list'), findsOneWidget);
  });

  testWidgets('saved lists are shown', (tester) async {
    final createdAt = DateTime.utc(2026, 6, 1);
    repository.lists.add(
      PackingList(
        id: 'list-1',
        name: 'Summer camping',
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    );

    await tester.pumpWidget(buildTestApp(const PackingListsScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Summer camping'), findsOneWidget);
    expect(find.text('0 items'), findsOneWidget);
  });

  testWidgets('create form validates required name', (tester) async {
    await tester.pumpWidget(buildTestApp(const CreatePackingListScreen()));
    await tester.pump();

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('List name is required'), findsOneWidget);
    expect(repository.saveCallCount, 0);
  });

  testWidgets('successful creation returns and displays the new list', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(const PackingListsScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Create packing list'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(PackingListCreationMethodScreen), findsOneWidget);

    await tester.tap(find.text('Create blank list'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CreatePackingListScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Weekend trip');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(PackingListsScreen), findsOneWidget);
    expect(find.text('Weekend trip'), findsOneWidget);
    expect(find.text('Packing list created'), findsOneWidget);
  });
}
