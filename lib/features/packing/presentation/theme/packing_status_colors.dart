import 'package:flutter/material.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';

/// Presentation-only status colors for the packing list module.
class PackingStatusColors {
  PackingStatusColors._();

  static Color packed(BuildContext context) {
    return _tone(
      context,
      light: Colors.green.shade600,
      dark: Colors.green.shade400,
    );
  }

  static Color packedComplete(BuildContext context) {
    return _tone(
      context,
      light: Colors.green.shade500,
      dark: Colors.green.shade300,
    );
  }

  static Color notPacked(BuildContext context) {
    return _tone(
      context,
      light: Colors.red.shade600,
      dark: Colors.red.shade400,
    );
  }

  static Color needsPurchase(BuildContext context) {
    return _tone(
      context,
      light: Colors.amber.shade700,
      dark: Colors.amber.shade600,
    );
  }

  static Color disabled(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color progressBar(BuildContext context, int percent) {
    if (percent >= 100) {
      return packedComplete(context);
    }
    if (percent >= 71) {
      return packed(context);
    }
    if (percent >= 31) {
      return needsPurchase(context);
    }
    return notPacked(context);
  }

  static Color itemAccentColor(BuildContext context, PackingItem item) {
    if (item.needsPurchase && !item.isPurchased) {
      return needsPurchase(context);
    }
    if (item.isPacked) {
      return packed(context);
    }
    return notPacked(context);
  }

  static Color chipBackground(BuildContext context, Color foreground) {
    final brightness = Theme.of(context).brightness;
    return foreground.withValues(
      alpha: brightness == Brightness.dark ? 0.18 : 0.12,
    );
  }

  static Color _tone(
    BuildContext context, {
    required Color light,
    required Color dark,
  }) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}

int packingOverviewProgressPercent(int packedCount, int itemCount) {
  if (itemCount == 0) {
    return 0;
  }
  return ((packedCount / itemCount) * 100).round();
}

int packingOverviewRemainingCount(int packedCount, int itemCount) {
  return itemCount - packedCount;
}

int packingOverviewToBuyCount(Iterable<PackingItem> items) {
  return items
      .where(
        (item) =>
            item.needsPurchase && !item.isPurchased && item.deletedAt == null,
      )
      .length;
}
