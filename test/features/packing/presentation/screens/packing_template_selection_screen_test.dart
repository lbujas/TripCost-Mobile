import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/app.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_list_from_templates_service.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_template_merge_service.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_template_selection_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/widgets/packing_template_card.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';

import '../../fake_packing_template_repository.dart';
import '../../packing_template_test_data.dart';

List<PackingTemplate> groupedSystemTemplateFixtures() {
  return [
    sampleSystemTemplate(
      id: 'sys_tpl_transport',
      nameKey: 'packingTemplateAirTravel',
      groupKey: 'packingTemplateGroupTransport',
    ),
    sampleSystemTemplate(
      id: 'sys_tpl_transport_2',
      nameKey: 'packingTemplateCarTravel',
      groupKey: 'packingTemplateGroupTransport',
    ),
    sampleSystemTemplate(
      id: 'sys_tpl_essentials',
      nameKey: 'packingTemplateBasicTrip',
      groupKey: 'packingTemplateGroupEssentials',
    ),
    sampleSystemTemplate(
      id: 'sys_tpl_essentials_2',
      nameKey: 'packingTemplateDocuments',
      groupKey: 'packingTemplateGroupEssentials',
    ),
    sampleSystemTemplate(
      id: 'sys_tpl_trip_type',
      nameKey: 'packingTemplateBeach',
      groupKey: 'packingTemplateGroupTripType',
    ),
    sampleSystemTemplate(
      id: 'sys_tpl_trip_type_2',
      nameKey: 'packingTemplateMountains',
      groupKey: 'packingTemplateGroupTripType',
    ),
    sampleSystemTemplate(
      id: 'sys_tpl_travellers',
      nameKey: 'packingTemplateTravellingWithChild',
      groupKey: 'packingTemplateGroupTravellers',
    ),
    sampleSystemTemplate(
      id: 'sys_tpl_travellers_2',
      nameKey: 'packingTemplateWithBaby',
      groupKey: 'packingTemplateGroupTravellers',
    ),
    sampleSystemTemplate(
      id: 'sys_tpl_before_1',
      nameKey: 'packingTemplateHomePrep',
      groupKey: 'packingTemplateGroupBeforeLeaving',
    ),
    sampleSystemTemplate(
      id: 'sys_tpl_before_2',
      nameKey: 'packingTemplateFinalChecks',
      groupKey: 'packingTemplateGroupBeforeLeaving',
    ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePackingTemplateRepository templateRepository;

  setUp(() {
    templateRepository = FakePackingTemplateRepository();
  });

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
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
        home: const PackingTemplateSelectionScreen(),
      ),
    );
  }

  Future<void> pumpSelectionScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();
  }

  Finder continueButton() => find.widgetWithText(ElevatedButton, 'Continue');

  Future<void> selectTemplate(WidgetTester tester, String label) async {
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  group('PackingTemplateSelectionScreen grouped UI', () {
    testWidgets('shows five system groups in required order', (tester) async {
      templateRepository.systemTemplates = groupedSystemTemplateFixtures();

      await pumpSelectionScreen(tester);

      expect(find.text('Transport').evaluate().single.renderObject, isNotNull);
      final titles = [
        'Transport',
        'Essentials',
        'Trip type',
        'Who is travelling',
        'Before leaving',
      ];
      for (final title in titles) {
        expect(find.text(title), findsOneWidget);
      }
      for (var index = 1; index < titles.length; index++) {
        expect(
          tester.getTopLeft(find.text(titles[index])).dy,
          greaterThan(tester.getTopLeft(find.text(titles[index - 1])).dy),
        );
      }
    });

    testWidgets('shows transport templates only under Transport', (
      tester,
    ) async {
      templateRepository.systemTemplates = groupedSystemTemplateFixtures();

      await pumpSelectionScreen(tester);

      final transportY = tester.getTopLeft(find.text('Transport')).dy;
      final essentialsY = tester.getTopLeft(find.text('Essentials')).dy;
      final airTravelY = tester.getTopLeft(find.text('Air travel')).dy;
      final roadTripY =
          tester.getTopLeft(find.text('Road trip across Europe')).dy;

      expect(airTravelY, greaterThan(transportY));
      expect(roadTripY, greaterThan(transportY));
      expect(airTravelY, lessThan(essentialsY));
      expect(roadTripY, lessThan(essentialsY));
    });

    testWidgets('shows essentials templates only under Essentials', (
      tester,
    ) async {
      templateRepository.systemTemplates = groupedSystemTemplateFixtures();

      await pumpSelectionScreen(tester);

      final essentialsY = tester.getTopLeft(find.text('Essentials')).dy;
      final tripTypeY = tester.getTopLeft(find.text('Trip type')).dy;
      final travelEssentialsY =
          tester.getTopLeft(find.text('Travel essentials')).dy;
      final documentsY =
          tester.getTopLeft(find.text('Documents & payments')).dy;

      expect(travelEssentialsY, greaterThan(essentialsY));
      expect(documentsY, greaterThan(essentialsY));
      expect(travelEssentialsY, lessThan(tripTypeY));
      expect(documentsY, lessThan(tripTypeY));
      expect(find.text('Choose the sections you need.'), findsOneWidget);
    });

    testWidgets('shows trip-type templates only under Trip type', (
      tester,
    ) async {
      templateRepository.systemTemplates = groupedSystemTemplateFixtures();

      await pumpSelectionScreen(tester);

      final tripTypeY = tester.getTopLeft(find.text('Trip type')).dy;
      final travellersY = tester.getTopLeft(find.text('Who is travelling')).dy;
      final beachY = tester.getTopLeft(find.text('Beach')).dy;
      final mountainsY = tester.getTopLeft(find.text('Mountains')).dy;

      expect(beachY, greaterThan(tripTypeY));
      expect(mountainsY, greaterThan(tripTypeY));
      expect(beachY, lessThan(travellersY));
      expect(mountainsY, lessThan(travellersY));
    });

    testWidgets('shows traveller templates only under Who is travelling', (
      tester,
    ) async {
      templateRepository.systemTemplates = groupedSystemTemplateFixtures();

      await pumpSelectionScreen(tester);

      final travellersY = tester.getTopLeft(find.text('Who is travelling')).dy;
      final beforeLeavingY = tester.getTopLeft(find.text('Before leaving')).dy;
      final withChildY =
          tester.getTopLeft(find.text('Travelling with a child')).dy;
      final withBabyY =
          tester.getTopLeft(find.text('Travelling with a baby')).dy;

      expect(withChildY, greaterThan(travellersY));
      expect(withBabyY, greaterThan(travellersY));
      expect(withChildY, lessThan(beforeLeavingY));
      expect(withBabyY, lessThan(beforeLeavingY));
    });

    testWidgets(
      'shows home preparation and final checks under Before leaving',
      (tester) async {
        templateRepository.systemTemplates = groupedSystemTemplateFixtures();

        await pumpSelectionScreen(tester);

        final beforeLeavingY =
            tester.getTopLeft(find.text('Before leaving')).dy;
        final homePrepY = tester.getTopLeft(find.text('Home preparation')).dy;
        final finalChecksY = tester.getTopLeft(find.text('Final checks')).dy;

        expect(homePrepY, greaterThan(beforeLeavingY));
        expect(finalChecksY, greaterThan(beforeLeavingY));
      },
    );

    testWidgets('shows user templates in My templates section', (tester) async {
      templateRepository.systemTemplates = [
        sampleSystemTemplate(
          id: 'sys_tpl_1',
          groupKey: 'packingTemplateGroupTransport',
          nameKey: 'packingTemplateAirTravel',
        ),
      ];
      templateRepository.userTemplates = [
        sampleUserTemplate(id: 'user_tpl_1', name: 'Weekend camping'),
      ];

      await pumpSelectionScreen(tester);

      expect(find.text('My templates'), findsOneWidget);
      expect(find.text('Weekend camping'), findsOneWidget);
    });

    testWidgets('user template without groupKey does not crash', (
      tester,
    ) async {
      templateRepository.userTemplates = [
        sampleUserTemplate(id: 'user_tpl_1', name: 'Custom list'),
      ];

      await pumpSelectionScreen(tester);

      expect(find.text('Custom list'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('unknown groupKey appears under Other templates', (
      tester,
    ) async {
      templateRepository.systemTemplates = [
        sampleSystemTemplate(
          id: 'unknown_tpl',
          nameKey: 'packingTemplateBasicTrip',
          groupKey: 'packingTemplateGroupUnknown',
        ),
      ];

      await pumpSelectionScreen(tester);

      expect(find.text('Other templates'), findsOneWidget);
      expect(find.text('Travel essentials'), findsOneWidget);
      expect(find.text('packingTemplateGroupUnknown'), findsNothing);
    });

    testWidgets('selecting templates in different groups updates summary', (
      tester,
    ) async {
      templateRepository.systemTemplates = [
        sampleSystemTemplate(
          id: 'sys_tpl_transport',
          nameKey: 'packingTemplateAirTravel',
          groupKey: 'packingTemplateGroupTransport',
        ),
        sampleSystemTemplate(
          id: 'sys_tpl_essentials',
          nameKey: 'packingTemplateBasicTrip',
          groupKey: 'packingTemplateGroupEssentials',
        ),
      ];

      await pumpSelectionScreen(tester);

      await selectTemplate(tester, 'Air travel');
      await selectTemplate(tester, 'Travel essentials');

      expect(find.text('2 templates selected'), findsOneWidget);
      expect(find.text('1 selected'), findsWidgets);
      expect(
        tester.widget<ElevatedButton>(continueButton()).onPressed,
        isNotNull,
      );
    });

    testWidgets('scrolling does not lose selection state', (tester) async {
      templateRepository.systemTemplates = groupedSystemTemplateFixtures();

      await pumpSelectionScreen(tester);

      await selectTemplate(tester, 'Air travel');
      await tester.drag(
        find.descendant(
          of: find.byType(PackingTemplateSelectionScreen),
          matching: find.byType(Scrollable),
        ),
        const Offset(0, -900),
      );
      await tester.pumpAndSettle();

      final checkbox = tester.widget<Checkbox>(
        find.descendant(
          of: find.ancestor(
            of: find.text('Air travel').last,
            matching: find.byType(PackingTemplateCard),
          ),
          matching: find.byType(Checkbox),
        ),
      );
      expect(checkbox.value, isTrue);
    });

    testWidgets('continue remains disabled with no selection', (tester) async {
      templateRepository.systemTemplates = groupedSystemTemplateFixtures();

      await pumpSelectionScreen(tester);

      expect(tester.widget<ElevatedButton>(continueButton()).onPressed, isNull);
    });

    testWidgets('multiple template selection still works', (tester) async {
      templateRepository.systemTemplates = [
        sampleSystemTemplate(
          id: 'sys_tpl_1',
          nameKey: 'packingTemplateBasicTrip',
          groupKey: 'packingTemplateGroupEssentials',
        ),
        sampleSystemTemplate(
          id: 'sys_tpl_2',
          nameKey: 'packingTemplateAirTravel',
          groupKey: 'packingTemplateGroupTransport',
        ),
      ];

      await pumpSelectionScreen(tester);

      await selectTemplate(tester, 'Travel essentials');
      await selectTemplate(tester, 'Air travel');

      expect(
        tester.widget<ElevatedButton>(continueButton()).onPressed,
        isNotNull,
      );
      expect(find.text('2 templates selected'), findsOneWidget);
    });

    testWidgets('checkbox tap does not double-toggle selection', (
      tester,
    ) async {
      templateRepository.systemTemplates = [
        sampleSystemTemplate(
          id: 'sys_tpl_1',
          nameKey: 'packingTemplateBasicTrip',
          groupKey: 'packingTemplateGroupEssentials',
        ),
      ];

      await pumpSelectionScreen(tester);

      final cardFinder = find.ancestor(
        of: find.text('Travel essentials').last,
        matching: find.byType(PackingTemplateCard),
      );
      final checkboxFinder = find.descendant(
        of: cardFinder,
        matching: find.byType(Checkbox),
      );

      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();
      expect(tester.widget<Checkbox>(checkboxFinder).value, isTrue);

      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();
      expect(tester.widget<Checkbox>(checkboxFinder).value, isFalse);
    });

    testWidgets('card body tap does not double-toggle selection', (
      tester,
    ) async {
      templateRepository.systemTemplates = [
        sampleSystemTemplate(
          id: 'sys_tpl_1',
          nameKey: 'packingTemplateBasicTrip',
          groupKey: 'packingTemplateGroupEssentials',
        ),
      ];

      await pumpSelectionScreen(tester);

      final cardFinder = find.ancestor(
        of: find.text('Travel essentials').last,
        matching: find.byType(PackingTemplateCard),
      );
      final checkboxFinder = find.descendant(
        of: cardFinder,
        matching: find.byType(Checkbox),
      );
      final inkWellFinder = find.descendant(
        of: cardFinder,
        matching: find.byType(InkWell),
      );

      await tester.tap(inkWellFinder);
      await tester.pumpAndSettle();
      expect(tester.widget<Checkbox>(checkboxFinder).value, isTrue);

      await tester.tap(inkWellFinder);
      await tester.pumpAndSettle();
      expect(tester.widget<Checkbox>(checkboxFinder).value, isFalse);
    });
  });
}
