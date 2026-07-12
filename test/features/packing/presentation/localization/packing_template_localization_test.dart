import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/localization/packing_template_localization.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('resolvePackingTemplateKey', () {
    late Set<String> templateNameKeys;
    late Set<String> templateDescriptionKeys;
    late Set<String> categoryKeys;
    late Set<String> itemKeys;
    late Set<String> unitKeys;
    late Set<String> noteKeys;

    setUpAll(() async {
      final jsonString = await rootBundle.loadString(
        'assets/data/packing_templates.json',
      );
      final templates = jsonDecode(jsonString) as List<dynamic>;

      templateNameKeys = {};
      templateDescriptionKeys = {};
      categoryKeys = {};
      itemKeys = {};
      unitKeys = {};
      noteKeys = {};

      for (final template in templates) {
        final map = template as Map<String, dynamic>;
        final nameKey = map['nameKey'] as String?;
        final descriptionKey = map['descriptionKey'] as String?;
        if (nameKey != null) {
          templateNameKeys.add(nameKey);
        }
        if (descriptionKey != null) {
          templateDescriptionKeys.add(descriptionKey);
        }

        final items = map['items'] as List<dynamic>? ?? const [];
        for (final item in items) {
          final itemMap = item as Map<String, dynamic>;
          final itemNameKey = itemMap['nameKey'] as String?;
          final categoryKey = itemMap['categoryKey'] as String?;
          final unitKey = itemMap['unitKey'] as String?;
          final noteKey = itemMap['noteKey'] as String?;

          if (itemNameKey != null) {
            itemKeys.add(itemNameKey);
          }
          if (categoryKey != null) {
            categoryKeys.add(categoryKey);
          }
          if (unitKey != null) {
            unitKeys.add(unitKey);
          }
          if (noteKey != null) {
            noteKeys.add(noteKey);
          }
        }
      }
    });

    test('resolves every system template name key', () {
      for (final key in templateNameKeys) {
        final resolved = resolvePackingTemplateKey(l10n, key);
        expect(resolved, isNot(equals(key)));
        expect(resolved, isNot(equals(l10n.packingUnknownTemplate)));
      }
    });

    test('resolves every description key', () {
      for (final key in templateDescriptionKeys) {
        final resolved = resolvePackingTemplateKey(l10n, key);
        expect(resolved, isNot(equals(key)));
        expect(resolved, isNot(equals(l10n.packingUnknownTemplate)));
      }
    });

    test('resolves every category key', () {
      for (final key in categoryKeys) {
        final resolved = resolvePackingTemplateKey(l10n, key);
        expect(resolved, isNot(equals(key)));
        expect(resolved, isNot(equals(l10n.packingUnknownCategory)));
      }
    });

    test('resolves every item key', () {
      for (final key in itemKeys) {
        final resolved = resolvePackingTemplateKey(l10n, key);
        expect(resolved, isNot(equals(key)));
        expect(resolved, isNot(equals(l10n.packingUnknownItem)));
      }
    });

    test('resolves all unit and note keys', () {
      for (final key in unitKeys) {
        final resolved = resolvePackingTemplateKey(l10n, key);
        expect(resolved, isNot(equals(key)));
        expect(resolved, isNot(equals(l10n.packingUnknownUnit)));
      }

      for (final key in noteKeys) {
        final resolved = resolvePackingTemplateKey(l10n, key);
        expect(resolved, isNot(equals(key)));
        expect(resolved, isNot(equals(l10n.packingUnknownTemplate)));
      }
    });

    test('unknown keys use fallback', () {
      expect(
        resolvePackingTemplateKey(l10n, 'packingTemplateCategoryMissing'),
        l10n.packingUnknownCategory,
      );
      expect(
        resolvePackingTemplateKey(l10n, 'packingTemplateItemMissing'),
        l10n.packingUnknownItem,
      );
      expect(
        resolvePackingTemplateKey(l10n, 'packingTemplateUnitMissing'),
        l10n.packingUnknownUnit,
      );
      expect(
        resolvePackingTemplateKey(l10n, 'packingTemplateTotallyUnknown'),
        l10n.packingUnknownTemplate,
      );
    });

    test('all locales resolve every bundled template key', () async {
      final jsonString = await rootBundle.loadString(
        'assets/data/packing_templates.json',
      );
      final templates = jsonDecode(jsonString) as List<dynamic>;

      final keys = <String>{};
      for (final template in templates) {
        final map = template as Map<String, dynamic>;
        keys.add(map['nameKey'] as String);
        keys.add(map['descriptionKey'] as String);
        for (final item in map['items'] as List<dynamic>) {
          final itemMap = item as Map<String, dynamic>;
          keys.add(itemMap['nameKey'] as String);
          keys.add(itemMap['categoryKey'] as String);
          keys.add(itemMap['unitKey'] as String);
          final noteKey = itemMap['noteKey'] as String?;
          if (noteKey != null) {
            keys.add(noteKey);
          }
        }
      }

      for (final locale in const [
        Locale('en'),
        Locale('pl'),
        Locale('de'),
        Locale('hr'),
        Locale('cs'),
        Locale('sk'),
        Locale('hu'),
      ]) {
        final localeL10n = await AppLocalizations.delegate.load(locale);
        for (final key in keys) {
          final resolved = resolvePackingTemplateKey(localeL10n, key);
          expect(resolved, isNot(equals(key)), reason: '$locale $key');
          expect(
            resolved,
            isNot(equals(localeL10n.packingUnknownTemplate)),
            reason: '$locale $key',
          );
          expect(
            resolved,
            isNot(equals(localeL10n.packingUnknownCategory)),
            reason: '$locale $key',
          );
          expect(
            resolved,
            isNot(equals(localeL10n.packingUnknownItem)),
            reason: '$locale $key',
          );
        }
      }
    });
  });

  group('resolvePackingTemplateName and description', () {
    test('user custom text is preserved', () {
      expect(
        resolvePackingTemplateName(
          l10n,
          nameKey: 'packingTemplateBasicTrip',
          customName: 'My camping list',
        ),
        'My camping list',
      );

      expect(
        resolvePackingTemplateDescription(
          l10n,
          descriptionKey: 'packingTemplateBasicTripDesc',
          customDescription: 'Custom notes',
        ),
        'Custom notes',
      );
    });
  });
}
