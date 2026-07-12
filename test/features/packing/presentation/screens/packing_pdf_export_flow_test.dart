import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:printing/printing.dart';
import 'package:travel_cost_planner_europe/app.dart';
import 'package:travel_cost_planner_europe/domain/models/app_settings.dart';
import 'package:travel_cost_planner_europe/domain/services/ad_service.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_category.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_list_detail_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_pdf_options_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_pdf_preview_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list_export_data.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_options.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/services/packing_list_pdf_service.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/services/packing_pdf_labels.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/services/packing_pdf_fonts.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_button.dart';

import '../../fake_packing_list_repository.dart';
import '../../packing_pdf_test_helpers.dart';

class FakeAdService extends AdService {
  FakeAdService({this.onShowInterstitialIfLoaded});

  int showInterstitialIfLoadedCallCount = 0;
  final Future<void> Function(FakeAdService fake)? onShowInterstitialIfLoaded;

  @override
  Future<void> showInterstitialIfLoaded() async {
    showInterstitialIfLoadedCallCount++;
    if (onShowInterstitialIfLoaded != null) {
      await onShowInterstitialIfLoaded!(this);
    }
  }
}

class TrackingPackingListPdfService extends PackingListPdfService {
  TrackingPackingListPdfService(super.fonts, {this.onGenerate});

  final VoidCallback? onGenerate;
  int generateCallCount = 0;

  @override
  Future<Uint8List> generate({
    required PackingListExportData data,
    required PackingPdfOptions options,
    required PackingPdfLabels labels,
  }) async {
    generateCallCount++;
    onGenerate?.call();
    return super.generate(data: data, options: options, labels: labels);
  }
}

PackingList _detailList() {
  final timestamp = DateTime.utc(2026, 6, 1, 10, 0);
  return PackingList(
    id: 'list-1',
    name: 'Weekend trip',
    createdAt: timestamp,
    updatedAt: timestamp,
    customCategories: [
      PackingCategory(
        id: 'cat-clothes',
        name: 'Clothes',
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
      PackingCategory(
        id: 'cat-shop',
        name: 'Shopping',
        sortOrder: 1,
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
      PackingItem(
        id: 'item-water',
        packingListId: 'list-1',
        name: 'Water',
        categoryId: 'cat-shop',
        needsPurchase: true,
        sortOrder: 1,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePackingListRepository repository;
  late PackingListPdfService pdfService;
  late FakeAdService adService;

  setUp(() async {
    repository = FakePackingListRepository(lists: [_detailList()]);
    pdfService = await createTestPackingListPdfService();
    adService = FakeAdService();
  });

  Widget buildTestApp(Widget child) {
    return ProviderScope(
      overrides: [
        adServiceProvider.overrideWithValue(adService),
        appSettingsProvider.overrideWith(
          (ref) async => AppSettings.defaults().copyWith(languageCode: 'en'),
        ),
        packingListRepositoryProvider.overrideWithValue(repository),
        packingListPdfServiceProvider.overrideWith((ref) async => pdfService),
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

  Future<void> openDetailMenu(WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestApp(const PackingListDetailScreen(packingListId: 'list-1')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const Key('packing_detail_menu')));
    await tester.pumpAndSettle();
  }

  Future<void> openPreviewFromOptions(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.byKey(const Key('packing_pdf_preview_button')),
      100,
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('packing_pdf_preview_button')));
    await tester.pump();
  }

  testWidgets('detail screen exposes Print / Export action', (tester) async {
    await openDetailMenu(tester);

    expect(find.text('Print / export list'), findsOneWidget);
  });

  testWidgets('options screen opens from detail menu', (tester) async {
    await openDetailMenu(tester);
    await tester.tap(find.text('Print / export list'));
    await tester.pumpAndSettle();

    expect(find.byType(PackingPdfOptionsScreen), findsOneWidget);
    expect(find.text('PDF options'), findsOneWidget);
  });

  testWidgets('scopes can be selected', (tester) async {
    await openDetailMenu(tester);
    await tester.tap(find.text('Print / export list'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Shopping list'));
    await tester.pump();

    expect(find.text('Include already purchased items'), findsOneWidget);
  });

  testWidgets('category selector appears only when required', (tester) async {
    await openDetailMenu(tester);
    await tester.tap(find.text('Print / export list'));
    await tester.pumpAndSettle();

    expect(find.text('Category'), findsNothing);

    await tester.tap(find.text('Selected category'));
    await tester.pumpAndSettle();

    expect(find.text('Category'), findsOneWidget);
  });

  testWidgets('preview action disabled when no items match', (tester) async {
    final timestamp = DateTime.utc(2026, 6, 1, 10, 0);
    repository = FakePackingListRepository(
      lists: [
        PackingList(
          id: 'list-1',
          name: 'All packed',
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
          ],
        ),
      ],
    );

    await openDetailMenu(tester);
    await tester.tap(find.text('Print / export list'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Only unpacked'));
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const Key('packing_pdf_preview_button')),
      100,
    );
    await tester.pump();

    final previewButton = tester.widget<AppButton>(
      find.byKey(const Key('packing_pdf_preview_button')),
    );
    expect(previewButton.onPressed, isNull);
    expect(find.text('0 items match these options'), findsOneWidget);
  });

  testWidgets('PDF preview opens immediately when no ad is available', (
    tester,
  ) async {
    await openDetailMenu(tester);
    await tester.tap(find.text('Print / export list'));
    await tester.pumpAndSettle();

    await openPreviewFromOptions(tester);
    await tester.pump(const Duration(milliseconds: 500));

    expect(adService.showInterstitialIfLoadedCallCount, 1);
    expect(find.byType(PackingPdfPreviewScreen), findsOneWidget);
    expect(find.byType(PdfPreview), findsOneWidget);
  });

  testWidgets('PDF preview opens after interstitial dismissal', (tester) async {
    final interstitialDismissed = Completer<void>();
    adService = FakeAdService(
      onShowInterstitialIfLoaded: (fake) async {
        await interstitialDismissed.future;
      },
    );

    await openDetailMenu(tester);
    await tester.tap(find.text('Print / export list'));
    await tester.pumpAndSettle();
    await openPreviewFromOptions(tester);
    await tester.pump(const Duration(milliseconds: 300));

    expect(adService.showInterstitialIfLoadedCallCount, 1);
    expect(find.byType(PackingPdfPreviewScreen), findsNothing);

    interstitialDismissed.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(PackingPdfPreviewScreen), findsOneWidget);
    expect(find.byType(PdfPreview), findsOneWidget);
  });

  testWidgets('PDF preview opens when interstitial presentation fails', (
    tester,
  ) async {
    adService = FakeAdService(
      onShowInterstitialIfLoaded: (_) async {
        throw Exception('Interstitial failed');
      },
    );

    await openDetailMenu(tester);
    await tester.tap(find.text('Print / export list'));
    await tester.pumpAndSettle();
    await openPreviewFromOptions(tester);
    await tester.pump(const Duration(milliseconds: 500));

    expect(adService.showInterstitialIfLoadedCallCount, 1);
    expect(find.byType(PackingPdfPreviewScreen), findsOneWidget);
    expect(find.byType(PdfPreview), findsOneWidget);
  });

  testWidgets('PDF is generated before interstitial is shown', (tester) async {
    var generateCompleted = false;

    final fonts = await PackingPdfFonts.load();
    pdfService = TrackingPackingListPdfService(
      fonts,
      onGenerate: () => generateCompleted = true,
    );
    adService = FakeAdService(
      onShowInterstitialIfLoaded: (_) async {
        expect(generateCompleted, isTrue);
      },
    );

    await openDetailMenu(tester);
    await tester.tap(find.text('Print / export list'));
    await tester.pumpAndSettle();
    await openPreviewFromOptions(tester);
    await tester.pump(const Duration(milliseconds: 500));

    expect(generateCompleted, isTrue);
    expect(adService.showInterstitialIfLoadedCallCount, 1);
    expect((pdfService as TrackingPackingListPdfService).generateCallCount, 1);
  });

  testWidgets('preview reuses generated PDF without regenerating', (
    tester,
  ) async {
    final fonts = await PackingPdfFonts.load();
    pdfService = TrackingPackingListPdfService(fonts);

    await openDetailMenu(tester);
    await tester.tap(find.text('Print / export list'));
    await tester.pumpAndSettle();
    await openPreviewFromOptions(tester);
    await tester.pump(const Duration(milliseconds: 500));

    expect((pdfService as TrackingPackingListPdfService).generateCallCount, 1);
    expect(find.byType(PdfPreview), findsOneWidget);
  });

  testWidgets('export does not modify repository data', (tester) async {
    final saveCountBefore = repository.saveCallCount;

    await openDetailMenu(tester);
    await tester.tap(find.text('Print / export list'));
    await tester.pumpAndSettle();
    await openPreviewFromOptions(tester);
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.saveCallCount, saveCountBefore);
    expect(repository.lists.single.items, hasLength(3));
  });
}
