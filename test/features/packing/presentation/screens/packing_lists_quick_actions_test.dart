import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/app.dart';
import 'package:travel_cost_planner_europe/domain/models/app_settings.dart';
import 'package:travel_cost_planner_europe/domain/services/ad_service.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_category.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_list_detail_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_lists_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_pdf_options_screen.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';

import '../../fake_packing_list_repository.dart';

PackingList overviewTestList() {
  final timestamp = DateTime.utc(2026, 6, 1, 10, 0);
  return PackingList(
    id: 'list-1',
    name: 'Croatia 2026',
    description: 'Family beach trip',
    createdAt: timestamp,
    updatedAt: timestamp,
    customCategories: [
      PackingCategory(
        id: 'cat-clothes',
        name: 'Clothes',
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    ],
    items: [
      PackingItem(
        id: 'item-shirt',
        packingListId: 'list-1',
        name: 'Shirt',
        categoryId: 'cat-clothes',
        isPacked: true,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
      PackingItem(
        id: 'item-pants',
        packingListId: 'list-1',
        name: 'Pants',
        categoryId: 'cat-clothes',
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePackingListRepository repository;

  setUp(() {
    repository = FakePackingListRepository(lists: [overviewTestList()]);
  });

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        adServiceProvider.overrideWithValue(AdService()),
        appSettingsProvider.overrideWith(
          (ref) async => AppSettings.defaults().copyWith(languageCode: 'en'),
        ),
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
        home: const PackingListsScreen(),
      ),
    );
  }

  Future<void> pumpOverview(WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();
  }

  group('PackingListsScreen quick actions', () {
    testWidgets('quick print opens existing PDF flow', (tester) async {
      await pumpOverview(tester);

      await tester.tap(find.byKey(const Key('packing_list_print_action')));
      await tester.pumpAndSettle();

      expect(find.byType(PackingPdfOptionsScreen), findsOneWidget);
      expect(find.byType(PackingListDetailScreen), findsNothing);
    });

    testWidgets('duplicate creates independent copy', (tester) async {
      await pumpOverview(tester);

      await tester.tap(find.byKey(const Key('packing_list_duplicate_action')));
      await tester.pumpAndSettle();

      expect(find.text('Croatia 2026 (Copy)'), findsOneWidget);
      expect(find.text('Croatia 2026'), findsOneWidget);
      expect(repository.saveCallCount, 1);
      expect(repository.lastSaved!.id, isNot('list-1'));
      expect(
        repository.lastSaved!.items.first.packingListId,
        repository.lastSaved!.id,
      );
      expect(find.text('Packing list duplicated'), findsOneWidget);
    });

    testWidgets('rename updates metadata', (tester) async {
      await pumpOverview(tester);

      await tester.tap(find.byKey(const Key('packing_list_rename_action')));
      await tester.pumpAndSettle();

      expect(find.text('Rename packing list'), findsOneWidget);

      await tester.enterText(
        find
            .descendant(
              of: find.byType(AlertDialog),
              matching: find.byType(TextField),
            )
            .first,
        'Croatia summer',
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Save'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Croatia summer'), findsOneWidget);
      expect(repository.lastSaved!.name, 'Croatia summer');
      expect(find.text('Packing list renamed'), findsOneWidget);
    });

    testWidgets('delete requires confirmation', (tester) async {
      await pumpOverview(tester);

      await tester.tap(find.byKey(const Key('packing_list_delete_action')));
      await tester.pumpAndSettle();

      expect(find.text('Delete packing list?'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);
      expect(find.textContaining('Croatia 2026'), findsWidgets);
      expect(repository.deleteSoftCallCount, 0);
    });

    testWidgets('cancel delete leaves list unchanged', (tester) async {
      await pumpOverview(tester);

      await tester.tap(find.byKey(const Key('packing_list_delete_action')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Croatia 2026'), findsOneWidget);
      expect(repository.deleteSoftCallCount, 0);
    });

    testWidgets('delete removes list', (tester) async {
      await pumpOverview(tester);

      await tester.tap(find.byKey(const Key('packing_list_delete_action')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Croatia 2026'), findsNothing);
      expect(repository.deleteSoftCallCount, 1);
      expect(find.text('Packing list deleted'), findsOneWidget);
    });

    testWidgets('quick actions do not open detail screen', (tester) async {
      await pumpOverview(tester);

      for (final key in [
        'packing_list_print_action',
        'packing_list_duplicate_action',
        'packing_list_rename_action',
        'packing_list_delete_action',
      ]) {
        await tester.tap(find.byKey(Key(key)).first);
        await tester.pumpAndSettle();

        if (find.byType(AlertDialog).evaluate().isNotEmpty) {
          await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
          await tester.pumpAndSettle();
        } else if (find.byType(PackingPdfOptionsScreen).evaluate().isNotEmpty) {
          await tester.pageBack();
          await tester.pumpAndSettle();
        }

        expect(find.byType(PackingListDetailScreen), findsNothing);
      }
    });

    testWidgets('tapping card still opens detail screen', (tester) async {
      await pumpOverview(tester);

      await tester.tap(find.text('Family beach trip'));
      await tester.pumpAndSettle();

      expect(find.byType(PackingListDetailScreen), findsOneWidget);
    });

    testWidgets('progress bar displays correctly', (tester) async {
      await pumpOverview(tester);

      expect(find.text('1 packed'), findsOneWidget);
      expect(find.text('1 remaining'), findsOneWidget);
      expect(find.text('Packed: 1 / 2'), findsOneWidget);
      expect(find.text('1 of 2 packed'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('localization works for quick action labels', (tester) async {
      await pumpOverview(tester);

      expect(find.byTooltip('Print / export list'), findsOneWidget);
      expect(find.byTooltip('Duplicate packing list'), findsOneWidget);
      expect(find.byTooltip('Rename packing list'), findsOneWidget);
      expect(find.byTooltip('Delete packing list'), findsOneWidget);
    });

    testWidgets('card layout fits narrow phone width without overflow', (
      tester,
    ) async {
      final binding = TestWidgetsFlutterBinding.instance;
      binding.platformDispatcher.views.first.physicalSize = const Size(
        320,
        640,
      );
      binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
      addTearDown(() {
        binding.platformDispatcher.views.first.resetPhysicalSize();
        binding.platformDispatcher.views.first.resetDevicePixelRatio();
      });

      final timestamp = DateTime.utc(2026, 6, 1, 10, 0);
      repository = FakePackingListRepository(
        lists: [
          PackingList(
            id: 'list-narrow',
            name:
                'Very long summer vacation packing list for Croatia twenty twenty six',
            description: 'Family beach trip with lots of luggage and extras',
            createdAt: timestamp,
            updatedAt: timestamp,
            customCategories: overviewTestList().customCategories,
            items: overviewTestList().items,
          ),
        ],
      );

      await pumpOverview(tester);

      expect(tester.takeException(), isNull);
      expect(
        find.textContaining('Very long summer vacation packing list'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('packing_list_print_action')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('packing_list_delete_action')),
        findsOneWidget,
      );
      expect(find.text('1 packed'), findsOneWidget);
      expect(find.text('1 remaining'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
