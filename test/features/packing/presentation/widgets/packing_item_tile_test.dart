import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/app.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/theme/packing_status_colors.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/widgets/packing_item_tile.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/widgets/packing_status_chip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final timestamp = DateTime.utc(2026, 6, 1, 10, 0);

  Widget buildTile({required PackingItem item, VoidCallback? onTogglePacked}) {
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
        body: PackingItemTile(
          item: item,
          onTogglePacked: onTogglePacked ?? () {},
          onToggleNeedsPurchase: () {},
          onTogglePurchased: () {},
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );
  }

  PackingItem baseItem({
    bool isPacked = false,
    bool needsPurchase = false,
    bool isPurchased = false,
  }) {
    return PackingItem(
      id: 'item-1',
      packingListId: 'list-1',
      name: 'Travel adapter',
      categoryId: 'cat-1',
      isPacked: isPacked,
      needsPurchase: needsPurchase,
      isPurchased: isPurchased,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  group('PackingItemTile status presentation', () {
    testWidgets('shows packed chip and checked checkbox for packed item', (
      tester,
    ) async {
      await tester.pumpWidget(buildTile(item: baseItem(isPacked: true)));
      await tester.pumpAndSettle();

      expect(find.text('Packed'), findsOneWidget);
      expect(find.text('Unpacked'), findsNothing);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      expect(find.byType(PackingStatusAccent), findsOneWidget);
    });

    testWidgets('shows unpacked chip for not packed item', (tester) async {
      await tester.pumpWidget(buildTile(item: baseItem()));
      await tester.pumpAndSettle();

      expect(find.text('Unpacked'), findsOneWidget);
      expect(find.text('Packed'), findsNothing);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    });

    testWidgets('shows purchase chips when needs purchase', (tester) async {
      await tester.pumpWidget(buildTile(item: baseItem(needsPurchase: true)));
      await tester.pumpAndSettle();

      expect(find.text('Needs purchase'), findsOneWidget);
      expect(find.text('Not purchased'), findsOneWidget);
      expect(find.text('Purchased'), findsNothing);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsWidgets);
    });

    testWidgets('shows purchased chip when purchase is complete', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTile(item: baseItem(needsPurchase: true, isPurchased: true)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Needs purchase'), findsOneWidget);
      expect(find.text('Purchased'), findsOneWidget);
      expect(find.text('Not purchased'), findsNothing);
    });

    testWidgets('uses amber accent when purchase is still pending', (
      tester,
    ) async {
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
              final accentColor = PackingStatusColors.itemAccentColor(
                context,
                baseItem(needsPurchase: true),
              );
              expect(accentColor, Colors.amber.shade700);

              return Scaffold(
                body: PackingItemTile(
                  item: baseItem(needsPurchase: true),
                  onTogglePacked: () {},
                  onToggleNeedsPurchase: () {},
                  onTogglePurchased: () {},
                  onEdit: () {},
                  onDelete: () {},
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Not purchased'), findsOneWidget);
    });
  });
}
