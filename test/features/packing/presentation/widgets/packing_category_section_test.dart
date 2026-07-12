import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/app.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_category.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/widgets/packing_category_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final timestamp = DateTime.utc(2026, 6, 1, 10, 0);

  Widget buildSection({
    required String categoryName,
    required List<PackingItem> items,
  }) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: TravelCostPlannerApp.supportedLocales,
      home: Scaffold(
        body: PackingCategorySection(
          category: PackingCategory(
            id: 'cat-1',
            name: categoryName,
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
          items: items,
          onTogglePacked: (_) {},
          onToggleNeedsPurchase: (_) {},
          onTogglePurchased: (_) {},
          onEdit: (_) {},
          onDelete: (_) {},
        ),
      ),
    );
  }

  PackingItem item({required String id, bool isPacked = false}) {
    return PackingItem(
      id: id,
      packingListId: 'list-1',
      name: 'Item $id',
      categoryId: 'cat-1',
      isPacked: isPacked,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  group('PackingCategorySection', () {
    testWidgets('shows category progress text', (tester) async {
      await tester.pumpWidget(
        buildSection(
          categoryName: 'Documents',
          items: [item(id: '1'), item(id: '2', isPacked: true)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('1 / 2 packed'), findsOneWidget);
    });

    testWidgets('shows green accent when all items are packed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: TravelCostPlannerApp.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: PackingCategorySection(
                  category: PackingCategory(
                    id: 'cat-1',
                    name: 'Documents',
                    createdAt: timestamp,
                    updatedAt: timestamp,
                  ),
                  items: [
                    item(id: '1', isPacked: true),
                    item(id: '2', isPacked: true),
                  ],
                  onTogglePacked: (_) {},
                  onToggleNeedsPurchase: (_) {},
                  onTogglePurchased: (_) {},
                  onEdit: (_) {},
                  onDelete: (_) {},
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 / 2 packed'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
    });
  });
}
