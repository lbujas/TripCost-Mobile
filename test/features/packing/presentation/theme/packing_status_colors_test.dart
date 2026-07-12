import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/theme/packing_status_colors.dart';

void main() {
  group('packingOverviewProgressPercent', () {
    test('returns 0 when itemCount is 0', () {
      expect(packingOverviewProgressPercent(0, 0), 0);
    });

    test('rounds correctly', () {
      expect(packingOverviewProgressPercent(1, 2), 50);
      expect(packingOverviewProgressPercent(3, 4), 75);
    });
  });

  group('packingOverviewRemainingCount', () {
    test('returns difference between total and packed', () {
      expect(packingOverviewRemainingCount(1, 3), 2);
      expect(packingOverviewRemainingCount(5, 5), 0);
    });
  });

  group('packingOverviewToBuyCount', () {
    test('counts only active unpurchased purchase items', () {
      final timestamp = DateTime.utc(2026, 6, 1);
      final items = [
        PackingItem(
          id: 'item-1',
          packingListId: 'list-1',
          name: 'Adapter',
          categoryId: 'cat-1',
          needsPurchase: true,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
        PackingItem(
          id: 'item-2',
          packingListId: 'list-1',
          name: 'Towel',
          categoryId: 'cat-1',
          needsPurchase: true,
          isPurchased: true,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
        PackingItem(
          id: 'item-3',
          packingListId: 'list-1',
          name: 'Shirt',
          categoryId: 'cat-1',
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
        PackingItem(
          id: 'item-4',
          packingListId: 'list-1',
          name: 'Deleted',
          categoryId: 'cat-1',
          needsPurchase: true,
          deletedAt: timestamp,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      ];

      expect(packingOverviewToBuyCount(items), 1);
    });
  });

  group('PackingStatusColors.progressBar', () {
    testWidgets('uses red for 0-30 percent in light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              expect(
                PackingStatusColors.progressBar(context, 10),
                Colors.red.shade600,
              );
              expect(
                PackingStatusColors.progressBar(context, 30),
                Colors.red.shade600,
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('uses amber for 31-70 percent in light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              expect(
                PackingStatusColors.progressBar(context, 31),
                Colors.amber.shade700,
              );
              expect(
                PackingStatusColors.progressBar(context, 70),
                Colors.amber.shade700,
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('uses green tiers for 71-100 percent in light theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              expect(
                PackingStatusColors.progressBar(context, 71),
                Colors.green.shade600,
              );
              expect(
                PackingStatusColors.progressBar(context, 99),
                Colors.green.shade600,
              );
              expect(
                PackingStatusColors.progressBar(context, 100),
                Colors.green.shade500,
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('uses lighter tones in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              expect(
                PackingStatusColors.progressBar(context, 10),
                Colors.red.shade400,
              );
              expect(
                PackingStatusColors.progressBar(context, 100),
                Colors.green.shade300,
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('PackingStatusColors.itemAccentColor', () {
    final timestamp = DateTime.utc(2026, 6, 1);

    testWidgets('prioritizes unpurchased purchase state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final item = PackingItem(
                id: 'item-1',
                packingListId: 'list-1',
                name: 'Adapter',
                categoryId: 'cat-1',
                needsPurchase: true,
                isPacked: true,
                createdAt: timestamp,
                updatedAt: timestamp,
              );

              expect(
                PackingStatusColors.itemAccentColor(context, item),
                Colors.amber.shade700,
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('uses packed green when packed without purchase need', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final item = PackingItem(
                id: 'item-1',
                packingListId: 'list-1',
                name: 'Shirt',
                categoryId: 'cat-1',
                isPacked: true,
                createdAt: timestamp,
                updatedAt: timestamp,
              );

              expect(
                PackingStatusColors.itemAccentColor(context, item),
                Colors.green.shade600,
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('uses not-packed red for unpacked items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final item = PackingItem(
                id: 'item-1',
                packingListId: 'list-1',
                name: 'Shirt',
                categoryId: 'cat-1',
                createdAt: timestamp,
                updatedAt: timestamp,
              );

              expect(
                PackingStatusColors.itemAccentColor(context, item),
                Colors.red.shade600,
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
