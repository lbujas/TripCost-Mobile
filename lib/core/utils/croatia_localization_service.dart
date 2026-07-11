import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CroatiaLocalizationService {
  CroatiaLocalizationService._();

  static String getRegionName(String regionId, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (regionId) {
      'istria' => l10n.region_istria,
      'kvarner' => l10n.region_kvarner,
      'zadar' => l10n.region_zadar,
      'sibenik' => l10n.region_sibenik,
      'split' => l10n.region_split,
      'makarska' => l10n.region_makarska,
      'ploce' => l10n.region_ploce,
      'dubrovnik' => l10n.region_dubrovnik,
      _ => regionId,
    };
  }

  static String getDestinationName(
    String destinationId,
    BuildContext context, {
    String? fallbackName,
  }) {
    final l10n = AppLocalizations.of(context);
    final localized = _lookupDestination(l10n, destinationId);
    if (localized != destinationId) {
      return localized;
    }
    return fallbackName ?? destinationId;
  }

  static String _lookupDestination(AppLocalizations l10n, String id) {
    return switch (id) {
      'pula' => l10n.destination_pula,
      'rovinj' => l10n.destination_rovinj,
      'porec' => l10n.destination_porec,
      'umag' => l10n.destination_umag,
      'medulin' => l10n.destination_medulin,
      'fazana' => l10n.destination_fazana,
      'novigrad' => l10n.destination_novigrad,
      'vrsar' => l10n.destination_vrsar,
      'motovun' => l10n.destination_motovun,
      'rabac' => l10n.destination_rabac,
      'labin' => l10n.destination_labin,
      'lovran' => l10n.destination_lovran,
      'rijeka' => l10n.destination_rijeka,
      'opatija' => l10n.destination_opatija,
      'crikvenica' => l10n.destination_crikvenica,
      'selce' => l10n.destination_selce,
      'novi_vinodolski' => l10n.destination_novi_vinodolski,
      'krk' => l10n.destination_krk,
      'baska' => l10n.destination_baska,
      'malinska' => l10n.destination_malinska,
      'punat' => l10n.destination_punat,
      'rab' => l10n.destination_rab,
      'senj' => l10n.destination_senj,
      'delnice' => l10n.destination_delnice,
      'zadar' => l10n.destination_zadar,
      'biograd_na_moru' => l10n.destination_biograd_na_moru,
      'sukosan' => l10n.destination_sukosan,
      'pakostane' => l10n.destination_pakostane,
      'nin' => l10n.destination_nin,
      'petrcane' => l10n.destination_petrcane,
      'pag' => l10n.destination_pag,
      'starigrad' => l10n.destination_starigrad,
      'vir' => l10n.destination_vir,
      'sibenik' => l10n.destination_sibenik,
      'vodice' => l10n.destination_vodice,
      'tribunj' => l10n.destination_tribunj,
      'primosten' => l10n.destination_primosten,
      'murter' => l10n.destination_murter,
      'rogoznica' => l10n.destination_rogoznica,
      'skradin' => l10n.destination_skradin,
      'tisno' => l10n.destination_tisno,
      'split' => l10n.destination_split,
      'trogir' => l10n.destination_trogir,
      'kastela' => l10n.destination_kastela,
      'podstrana' => l10n.destination_podstrana,
      'omis' => l10n.destination_omis,
      'solin' => l10n.destination_solin,
      'stobrec' => l10n.destination_stobrec,
      'dugi_rat' => l10n.destination_dugi_rat,
      'brela' => l10n.destination_brela,
      'baska_voda' => l10n.destination_baska_voda,
      'makarska' => l10n.destination_makarska,
      'tucepi' => l10n.destination_tucepi,
      'podgora' => l10n.destination_podgora,
      'igrane' => l10n.destination_igrane,
      'zivogosce' => l10n.destination_zivogosce,
      'drvenik' => l10n.destination_drvenik,
      'gradac' => l10n.destination_gradac,
      'ploce' => l10n.destination_ploce,
      'zaostrog' => l10n.destination_zaostrog,
      'dubrovnik' => l10n.destination_dubrovnik,
      'cavtat' => l10n.destination_cavtat,
      'mlini' => l10n.destination_mlini,
      'plat' => l10n.destination_plat,
      'slano' => l10n.destination_slano,
      'ston' => l10n.destination_ston,
      'orebic' => l10n.destination_orebic,
      _ => id,
    };
  }
}
