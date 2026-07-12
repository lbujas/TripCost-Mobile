import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/app.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_list_from_templates_service.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_template_merge_service.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/create_packing_list_from_templates_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/create_packing_list_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_list_creation_method_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_list_detail_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_lists_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_template_selection_screen.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';

import '../../fake_packing_list_repository.dart';
import '../../fake_packing_template_repository.dart';
import '../../packing_template_test_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePackingListRepository listRepository;
  late FakePackingTemplateRepository templateRepository;

  setUp(() {
    listRepository = FakePackingListRepository();
    templateRepository = FakePackingTemplateRepository(
      systemTemplates: [
        sampleSystemTemplate(
          id: 'sys_tpl_1',
          nameKey: 'packingTemplateBasicTrip',
          groupKey: 'packingTemplateGroupEssentials',
          items: const [
            PackingTemplateItem(
              id: 'sys_item_1',
              nameKey: 'packingTemplateItemIdentityDocument',
              categoryKey: 'packingTemplateCategoryDocuments',
            ),
          ],
        ),
        sampleSystemTemplate(
          id: 'sys_tpl_2',
          nameKey: 'packingTemplateAirTravel',
          groupKey: 'packingTemplateGroupTransport',
          items: const [
            PackingTemplateItem(
              id: 'sys_item_2',
              nameKey: 'packingTemplateItemPassport',
              categoryKey: 'packingTemplateCategoryDocuments',
            ),
          ],
        ),
      ],
    );
  });

  Widget buildTestApp(Widget child) {
    return ProviderScope(
      overrides: [
        packingListRepositoryProvider.overrideWithValue(listRepository),
        packingTemplateRepositoryProvider.overrideWithValue(templateRepository),
        packingTemplateMergeServiceProvider.overrideWithValue(
          const PackingTemplateMergeService(),
        ),
        packingListFromTemplatesServiceProvider.overrideWithValue(
          PackingListFromTemplatesService(const PackingTemplateMergeService()),
        ),
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

  Future<void> openCreationMethod(WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(const PackingListsScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Create packing list'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> tapCreateListButton(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create list'));
    await tester.pump();
  }

  Future<void> openCreateFromTemplatesForm(WidgetTester tester) async {
    await openCreationMethod(tester);
    await tester.tap(find.text('Create from templates'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Travel essentials'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Travel essentials').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  Future<void> pickDateFromCalendar(
    WidgetTester tester, {
    required int calendarButtonIndex,
    required String dayLabel,
  }) async {
    await tester.tap(
      find.byIcon(Icons.calendar_today_outlined).at(calendarButtonIndex),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(dayLabel).last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();
  }

  testWidgets('create action shows blank and template choice', (tester) async {
    await openCreationMethod(tester);

    expect(find.byType(PackingListCreationMethodScreen), findsOneWidget);
    expect(find.text('Create blank list'), findsOneWidget);
    expect(find.text('Create from templates'), findsOneWidget);
  });

  testWidgets('blank flow still opens existing form', (tester) async {
    await openCreationMethod(tester);

    await tester.tap(find.text('Create blank list'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CreatePackingListScreen), findsOneWidget);
  });

  testWidgets('template screen shows grouped system templates', (tester) async {
    await openCreationMethod(tester);

    await tester.tap(find.text('Create from templates'));
    await tester.pumpAndSettle();

    expect(find.byType(PackingTemplateSelectionScreen), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Essentials'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Essentials'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Travel essentials'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Travel essentials'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Air travel'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Air travel'), findsWidgets);
    expect(find.text('System templates'), findsNothing);
  });

  testWidgets('multiple templates can be selected', (tester) async {
    await openCreationMethod(tester);
    await tester.tap(find.text('Create from templates'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Travel essentials'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Travel essentials').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Air travel'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Air travel').last);
    await tester.pumpAndSettle();

    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    expect(tester.widget<ElevatedButton>(continueButton).onPressed, isNotNull);

    await tester.tap(continueButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CreatePackingListFromTemplatesScreen), findsOneWidget);
  });

  testWidgets('continue disabled with no selection', (tester) async {
    await openCreationMethod(tester);
    await tester.tap(find.text('Create from templates'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    expect(tester.widget<ElevatedButton>(continueButton).onPressed, isNull);
  });

  testWidgets('selected count and merged item count update', (tester) async {
    await openCreationMethod(tester);
    await tester.tap(find.text('Create from templates'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Travel essentials'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Travel essentials').last);
    await tester.pumpAndSettle();

    var continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    expect(tester.widget<ElevatedButton>(continueButton).onPressed, isNotNull);

    await tester.scrollUntilVisible(
      find.text('Air travel'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Air travel').last);
    await tester.pumpAndSettle();

    continueButton = find.widgetWithText(ElevatedButton, 'Continue');
    expect(tester.widget<ElevatedButton>(continueButton).onPressed, isNotNull);
  });

  testWidgets('create form validates name', (tester) async {
    await openCreateFromTemplatesForm(tester);

    expect(find.byType(CreatePackingListFromTemplatesScreen), findsOneWidget);

    await tapCreateListButton(tester);

    expect(find.text('List name is required'), findsWidgets);
    expect(listRepository.saveCallCount, 0);
  });

  testWidgets('validates date range', (tester) async {
    await openCreateFromTemplatesForm(tester);

    await tester.enterText(find.byType(TextField).first, 'Trip with dates');
    await pickDateFromCalendar(tester, calendarButtonIndex: 0, dayLabel: '20');
    await pickDateFromCalendar(tester, calendarButtonIndex: 1, dayLabel: '10');

    await tapCreateListButton(tester);

    expect(
      find.text('Return date cannot be earlier than departure date'),
      findsOneWidget,
    );
    expect(listRepository.saveCallCount, 0);
  });

  testWidgets('successful creation persists and opens new list', (
    tester,
  ) async {
    await openCreateFromTemplatesForm(tester);

    await tester.enterText(find.byType(TextField).first, 'Template trip');
    await tapCreateListButton(tester);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(PackingListsScreen), findsOneWidget);
    expect(find.text('Template trip'), findsWidgets);
    expect(find.text('Packing list created from templates'), findsOneWidget);
    expect(listRepository.saveCallCount, 1);
    expect(find.byType(PackingListDetailScreen), findsOneWidget);
  });

  testWidgets('generated list contains localized names rather than raw keys', (
    tester,
  ) async {
    await openCreateFromTemplatesForm(tester);

    await tester.enterText(find.byType(TextField).first, 'Localized list');
    await tapCreateListButton(tester);
    await tester.pump(const Duration(milliseconds: 300));

    final saved = listRepository.lastSaved!;
    expect(saved.items.single.name, 'Identity document');
    expect(saved.customCategories.single.name, 'Documents');
    expect(saved.items.single.name, isNot(contains('packingTemplateItem')));
  });

  testWidgets('repository error displays retry', (tester) async {
    templateRepository.systemLoadError = Exception('failed');

    await openCreationMethod(tester);
    await tester.tap(find.text('Create from templates'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Failed to load templates'), findsOneWidget);

    templateRepository.systemLoadError = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Transport'), findsOneWidget);
  });
}
