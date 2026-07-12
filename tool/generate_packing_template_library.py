#!/usr/bin/env python3
"""Generate modular packing template library for the Flutter app."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tool"))

from data.templates import (  # noqa: E402
    GROUP_BEFORE_LEAVING,
    GROUP_ESSENTIALS,
    GROUP_TRANSPORT,
    GROUP_TRAVELLERS,
    GROUP_TRIP_TYPE,
    LEGACY_TEMPLATES,
    NEW_MODULAR_TEMPLATES,
    NEW_TRANSPORT_TEMPLATES,
    TRAVELLER_TEMPLATES,
    TRIP_TYPE_TEMPLATES,
    TRANSPORT_TEMPLATES,
    build_all_system_templates,
    build_car_travel_template,
    build_template,
)
from data.translations.catalog import ALL_NEW_TRANSLATIONS, ROAD_TRIP_EXTRA  # noqa: E402
from road_trip_translations import NEW_ITEM_TRANSLATIONS as ROAD_TRIP_ITEMS  # noqa: E402

PACKING_JSON = ROOT / "assets" / "data" / "packing_templates.json"
L10N_DIR = ROOT / "lib" / "l10n"
LOCALES = ("en", "pl", "de", "hr", "cs", "sk", "hu")
ARB_FILES = {locale: L10N_DIR / f"app_{locale}.arb" for locale in LOCALES}

ROAD_TRIP_DART = (
    ROOT
    / "lib"
    / "features"
    / "packing"
    / "presentation"
    / "localization"
    / "packing_template_localization_road_trip.dart"
)
MODULAR_DART = (
    ROOT
    / "lib"
    / "features"
    / "packing"
    / "presentation"
    / "localization"
    / "packing_template_localization_modular.dart"
)
TRANSPORT_DART = (
    ROOT
    / "lib"
    / "features"
    / "packing"
    / "presentation"
    / "localization"
    / "packing_template_localization_transport.dart"
)
MAIN_DART = (
    ROOT
    / "lib"
    / "features"
    / "packing"
    / "presentation"
    / "localization"
    / "packing_template_localization.dart"
)

ROAD_TRIP_CATEGORIES = {
    "packingTemplateCategoryRoutePreparation",
    "packingTemplateCategoryVehicleFluids",
    "packingTemplateCategoryTyresBrakes",
    "packingTemplateCategoryLightsVisibility",
    "packingTemplateCategorySafetyEquipment",
    "packingTemplateCategoryEmergencyTools",
    "packingTemplateCategoryLuggageLoading",
    "packingTemplateCategoryFinalDepartureChecks",
}

ROAD_TRIP_CATEGORIES |= set(ROAD_TRIP_EXTRA.get("categories", {}))

MODULAR_CATEGORIES = set(ALL_NEW_TRANSLATIONS.get("modular_categories", {}))
MODULAR_KEYS = set(ALL_NEW_TRANSLATIONS.get("modular_keys", {}))
TRANSPORT_CATEGORIES = set(ALL_NEW_TRANSLATIONS.get("transport_categories", {}))
TRANSPORT_KEYS = set(ALL_NEW_TRANSLATIONS.get("transport_keys", {}))

CAR_TRAVEL_DESC = {
    "en": "Vehicle-focused Europe road trip: route planning, fluids, tyres, lights, safety gear, and departure checks",
    "pl": "Europejska podróż samochodem — pojazd: plan trasy, płyny, opony, światła, bezpieczeństwo i kontrole przed wyjazdem",
    "de": "Europa-Autoreise mit Fahrzeugfokus: Routenplanung, Flüssigkeiten, Reifen, Licht, Sicherheit und Abfahrtschecks",
    "hr": "Europsko cestovno putovanje — fokus na vozilo: ruta, tekućine, gume, svjetla, sigurnost i provjere prije polaska",
    "cs": "Evropská cesta autem — zaměření na vozidlo: trasa, kapaliny, pneumatiky, světla, bezpečnost a kontroly před odjezdem",
    "sk": "Európska cesta autom — zameranie na vozidlo: trasa, kvapaliny, pneumatiky, svetlá, bezpečnosť a kontroly pred odchodom",
    "hu": "Európai autós út — járműközpontú: útvonal, folyadékok, gumiabroncsok, világítás, biztonság és indulás előtti ellenőrzések",
}


def collect_all_translations() -> dict[str, dict[str, str]]:
    merged: dict[str, dict[str, str]] = {}
    sources = [
        ROAD_TRIP_ITEMS,
        ROAD_TRIP_EXTRA.get("categories", {}),
        ROAD_TRIP_EXTRA.get("items", {}),
        ALL_NEW_TRANSLATIONS.get("modular_categories", {}),
        ALL_NEW_TRANSLATIONS.get("modular_keys", {}),
        ALL_NEW_TRANSLATIONS.get("transport_categories", {}),
        ALL_NEW_TRANSLATIONS.get("transport_keys", {}),
        ALL_NEW_TRANSLATIONS.get("template_meta", {}),
        ALL_NEW_TRANSLATIONS.get("legacy_template_meta", {}),
        ALL_NEW_TRANSLATIONS.get("group_meta", {}),
        {"packingTemplateCarTravelDesc": CAR_TRAVEL_DESC},
    ]
    for source in sources:
        for key, translations in source.items():
            merged[key] = translations
    return merged


def key_to_dart_property(key: str) -> str:
    return key[0].lower() + key[1:]


def generate_dart_switch_cases(keys: list[str]) -> str:
    lines: list[str] = []
    for key in sorted(keys):
        prop = key_to_dart_property(key)
        lines.append(f"    case '{key}':")
        lines.append(f"      return l10n.{prop};")
    return "\n".join(lines)


def generate_resolver_dart(
    function_name: str,
    doc_comment: str,
    keys: set[str],
) -> str:
    switch_body = generate_dart_switch_cases(sorted(keys))
    return f"""import 'package:flutter_gen/gen_l10n/app_localizations.dart';

{doc_comment}
String? {function_name}(AppLocalizations l10n, String key) {{
  switch (key) {{
{switch_body}
    default:
      return null;
  }}
}}
"""


def load_arb(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def merge_arb_files(translations: dict[str, dict[str, str]]) -> None:
    for locale, path in ARB_FILES.items():
        data = load_arb(path)
        for key, locale_values in translations.items():
            if locale in locale_values:
                data[key] = locale_values[locale]
        path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )


def load_existing_templates() -> list[dict[str, Any]]:
    return json.loads(PACKING_JSON.read_text(encoding="utf-8"))


def update_packing_templates(templates: list[dict[str, Any]]) -> None:
    PACKING_JSON.write_text(
        json.dumps(templates, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


ORIGINAL_TEMPLATE_ORDER = (
    "sys_tpl_basic_trip",
    "sys_tpl_air_travel",
    "sys_tpl_train_bus",
    "sys_tpl_beach",
    "sys_tpl_mountains",
    "sys_tpl_camping",
    "sys_tpl_business",
    "sys_tpl_with_child",
    "sys_tpl_with_pet",
)


def build_full_template_list() -> list[dict[str, Any]]:
    return build_all_system_templates()


def collect_keys_for_template(template: dict[str, Any]) -> set[str]:
    keys = {template["nameKey"], template["descriptionKey"]}
    if group_key := template.get("groupKey"):
        keys.add(group_key)
    for item in template["items"]:
        keys.add(item["nameKey"])
        keys.add(item["categoryKey"])
        keys.add(item["unitKey"])
        if note := item.get("noteKey"):
            keys.add(note)
    return keys


def update_main_localization_dart() -> None:
    text = MAIN_DART.read_text(encoding="utf-8")
    imports = [
        (
            "packing_template_localization_road_trip.dart",
            "resolveRoadTripPackingTemplateKey",
        ),
        (
            "packing_template_localization_modular.dart",
            "resolveModularPackingTemplateKey",
        ),
        (
            "packing_template_localization_transport.dart",
            "resolveTransportPackingTemplateKey",
        ),
    ]
    for module, _ in imports:
        import_line = (
            "import 'package:travel_cost_planner_europe/features/packing/presentation/"
            f"localization/{module}';\n"
        )
        if import_line not in text:
            text = text.replace(
                "import 'package:flutter_gen/gen_l10n/app_localizations.dart';\n",
                "import 'package:flutter_gen/gen_l10n/app_localizations.dart';\n"
                + import_line,
                1,
            )

    resolver_chain = """  final roadTrip = resolveRoadTripPackingTemplateKey(l10n, key);
  if (roadTrip != null) {
    return roadTrip;
  }
  final modular = resolveModularPackingTemplateKey(l10n, key);
  if (modular != null) {
    return modular;
  }
  final transport = resolveTransportPackingTemplateKey(l10n, key);
  if (transport != null) {
    return transport;
  }"""

    if "resolveModularPackingTemplateKey" not in text:
        text = text.replace(
            "String resolvePackingTemplateKey(AppLocalizations l10n, String key) {\n"
            "  final roadTrip = resolveRoadTripPackingTemplateKey(l10n, key);\n"
            "  if (roadTrip != null) {\n"
            "    return roadTrip;\n"
            "  }\n\n"
            "  switch (key) {",
            "String resolvePackingTemplateKey(AppLocalizations l10n, String key) {\n"
            f"{resolver_chain}\n\n"
            "  switch (key) {",
        )
    MAIN_DART.write_text(text, encoding="utf-8")


def apply_changes(templates: list[dict[str, Any]], translations: dict[str, dict[str, str]]) -> None:
    car = next(t for t in templates if t["id"] == "sys_tpl_car_travel")
    modular_templates = [
        template
        for template in templates
        if template["id"] in {meta["id"] for meta in NEW_MODULAR_TEMPLATES}
        or template["id"] in {meta["id"] for meta in LEGACY_TEMPLATES}
    ]
    transport_templates = [
        template
        for template in templates
        if template["id"] in {meta["id"] for meta in NEW_TRANSPORT_TEMPLATES}
        or template["id"] in {meta["id"] for meta in TRANSPORT_TEMPLATES}
        or template["id"] in {meta["id"] for meta in TRIP_TYPE_TEMPLATES}
        or template["id"] in {meta["id"] for meta in TRAVELLER_TEMPLATES}
        or template["id"] == "sys_tpl_car_travel"
    ]

    road_resolver_keys = collect_keys_for_template(car)
    modular_resolver_keys = {
        key
        for template in modular_templates
        for key in collect_keys_for_template(template)
    }
    transport_resolver_keys = {
        key
        for template in transport_templates
        for key in collect_keys_for_template(template)
    }

    update_packing_templates(templates)
    merge_arb_files(translations)
    ROAD_TRIP_DART.write_text(
        generate_resolver_dart(
            "resolveRoadTripPackingTemplateKey",
            "/// Resolver for road-trip / car-travel packing template keys.",
            road_resolver_keys,
        ),
        encoding="utf-8",
    )
    MODULAR_DART.write_text(
        generate_resolver_dart(
            "resolveModularPackingTemplateKey",
            "/// Resolver for modular packing template keys (documents, clothing, etc.).",
            modular_resolver_keys,
        ),
        encoding="utf-8",
    )
    TRANSPORT_DART.write_text(
        generate_resolver_dart(
            "resolveTransportPackingTemplateKey",
            "/// Resolver for transport and season-specific packing template keys.",
            transport_resolver_keys,
        ),
        encoding="utf-8",
    )
    update_main_localization_dart()


def print_summary(templates: list[dict[str, Any]]) -> None:
    print(f"Total templates: {len(templates)}")
    for template in templates:
        print(f"  {template['id']}: {len(template['items'])} items")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true", help="Write into project files")
    args = parser.parse_args()

    templates = build_full_template_list()
    translations = collect_all_translations()

    print_summary(templates)
    print(f"Translation keys: {len(translations)}")

    if args.apply:
        apply_changes(templates, translations)
        print("\nApplied changes to project files.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
