import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VignettePurchaseLocalizationService {
  VignettePurchaseLocalizationService._();

  static String getNotes(String notesKey, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (notesKey) {
      'vignettePurchaseNotes_at' => l10n.vignettePurchaseNotes_at,
      'vignettePurchaseNotes_sk' => l10n.vignettePurchaseNotes_sk,
      'vignettePurchaseNotes_hu' => l10n.vignettePurchaseNotes_hu,
      'vignettePurchaseNotes_si' => l10n.vignettePurchaseNotes_si,
      'vignettePurchaseNotes_cz' => l10n.vignettePurchaseNotes_cz,
      _ => '',
    };
  }
}
