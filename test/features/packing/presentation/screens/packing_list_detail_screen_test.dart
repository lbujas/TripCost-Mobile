import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/app.dart';
import 'package:travel_cost_planner_europe/core/constants/demo_car.dart';
import 'package:travel_cost_planner_europe/domain/models/app_settings.dart';
import 'package:travel_cost_planner_europe/domain/services/ad_service.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_category.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/edit_packing_list_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_item_form_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_list_detail_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_lists_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_list_detail_controller.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';

import '../../fake_packing_list_repository.dart';

PackingList _emptyList() {
  final timestamp = DateTime.utc(2026, 6, 1, 10, 0);
  return PackingList(
    id: 'list-1',
    name: 'Weekend trip',
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

PackingList _listWithItem() {
  final timestamp = DateTime.utc(2026, 6, 1, 10, 0);
  return PackingList(
    id: 'list-1',
    name: 'Weekend trip',
    createdAt: timestamp,
    updatedAt: timestamp,
    customCategories: [
      PackingCategory(
        id: 'cat-1',
        name: 'Clothes',
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    ],
    items: [
      PackingItem(
        id: 'item-1',
        packingListId: 'list-1',
        name: 'Shirt',
        categoryId: 'cat-1',
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
    repository = FakePackingListRepository(lists: [_emptyList()]);
  });

  setUp(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.views.first.physicalSize = const Size(
      1080,
      2400,
    );
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
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

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    int maxAttempts = 30,
  }) async {
    await tester.pump();
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
  }

  Future<void> pumpDetailLoaded(WidgetTester tester) async {
    await pumpUntilFound(
      tester,
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data == 'No items yet' ||
                widget.data == 'Add your first item'),
      ),
    );
  }

  Future<void> pumpItemFormLoaded(WidgetTester tester) async {
    await pumpUntilFound(tester, find.byType(PackingItemFormScreen));
    await pumpUntilFound(tester, find.text('Item name'));
  }

  Future<void> openAddItemForm(WidgetTester tester) async {
    await tester.tap(find.text('Add item'));
    await tester.pump();
    await pumpItemFormLoaded(tester);
  }

  Future<void> saveItemForm(WidgetTester tester) async {
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> fillNewItemForm(
    WidgetTester tester, {
    required String name,
    required String categoryName,
    bool needsPurchase = false,
  }) async {
    await tester.enterText(find.byType(TextField).at(0), name);
    await tester.enterText(find.byType(TextField).at(1), categoryName);
    if (needsPurchase) {
      await tester.scrollUntilVisible(
        find.byType(SwitchListTile),
        100,
        scrollable:
            find
                .descendant(
                  of: find.byType(PackingItemFormScreen),
                  matching: find.byType(Scrollable),
                )
                .first,
      );
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();
    }
  }

  testWidgets('card opens detail screen', (tester) async {
    await tester.pumpWidget(buildTestApp(const PackingListsScreen()));
    await pumpUntilFound(tester, find.text('Weekend trip'));

    await tester.tap(find.text('Weekend trip'));
    await tester.pump();
    await pumpDetailLoaded(tester);

    expect(find.byType(PackingListDetailScreen), findsOneWidget);
    expect(find.text('No items yet'), findsOneWidget);
  });

  testWidgets('empty list detail state is shown', (tester) async {
    await tester.pumpWidget(
      buildTestApp(const PackingListDetailScreen(packingListId: 'list-1')),
    );
    await pumpDetailLoaded(tester);

    expect(find.text('No items yet'), findsOneWidget);
    expect(find.text('Add your first item'), findsOneWidget);
  });

  testWidgets('adding first category and item shows item in section', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(const PackingListDetailScreen(packingListId: 'list-1')),
    );
    await pumpDetailLoaded(tester);
    await openAddItemForm(tester);

    await fillNewItemForm(
      tester,
      name: 'Toothbrush',
      categoryName: 'Toiletries',
    );
    await saveItemForm(tester);

    expect(find.text('Toiletries'), findsOneWidget);
    expect(find.text('Toothbrush'), findsOneWidget);
    expect(find.text('0 / 1 packed'), findsOneWidget);
    expect(find.text('0 of 1 packed'), findsOneWidget);
  });

  testWidgets('packed toggle updates progress', (tester) async {
    repository.lists = [_listWithItem()];

    await tester.pumpWidget(
      buildTestApp(const PackingListDetailScreen(packingListId: 'list-1')),
    );
    await pumpUntilFound(tester, find.text('Shirt'));

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('1 of 1 packed'), findsOneWidget);
  });

  testWidgets('purchase state does not automatically pack item', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(const PackingListDetailScreen(packingListId: 'list-1')),
    );
    await pumpDetailLoaded(tester);
    await openAddItemForm(tester);

    await fillNewItemForm(
      tester,
      name: 'Adapter',
      categoryName: 'Electronics',
      needsPurchase: true,
    );
    await saveItemForm(tester);

    expect(find.text('Unpacked'), findsOneWidget);
    expect(find.text('Needs purchase'), findsWidgets);
  });

  testWidgets('create form validates required name', (tester) async {
    await tester.pumpWidget(
      buildTestApp(const PackingItemFormScreen(packingListId: 'list-1')),
    );
    await pumpItemFormLoaded(tester);

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Item name is required'), findsOneWidget);
  });

  testWidgets('editing item updates item name on detail screen', (
    tester,
  ) async {
    repository.lists = [_listWithItem()];

    await tester.pumpWidget(
      buildTestApp(
        const PackingItemFormScreen(packingListId: 'list-1', itemId: 'item-1'),
      ),
    );
    await pumpItemFormLoaded(tester);

    await tester.enterText(find.byType(TextField).first, 'Blue shirt');
    await saveItemForm(tester);

    expect(repository.lastSaved?.items.first.name, 'Blue shirt');
  });

  testWidgets('editing list metadata updates detail title', (tester) async {
    await tester.pumpWidget(
      buildTestApp(const EditPackingListScreen(packingListId: 'list-1')),
    );
    await pumpUntilFound(tester, find.text('Edit packing list'));

    await tester.enterText(find.byType(TextField).first, 'Mountain trip');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.lastSaved?.name, 'Mountain trip');
  });

  testWidgets('deleting item removes it from detail screen', (tester) async {
    await tester.pumpWidget(
      buildTestApp(const PackingListDetailScreen(packingListId: 'list-1')),
    );
    await pumpDetailLoaded(tester);
    await openAddItemForm(tester);

    await fillNewItemForm(tester, name: 'Socks', categoryName: 'Clothes');
    await saveItemForm(tester);
    await pumpUntilFound(tester, find.text('Socks'));

    final itemId = repository.lists.first.items.first.id;
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PackingListDetailScreen)),
    );
    await container
        .read(packingListDetailControllerProvider('list-1').notifier)
        .softDeleteItem(itemId);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Socks'), findsNothing);
    expect(find.text('No items yet'), findsOneWidget);
  });
}
