#!/usr/bin/env python3
"""Generate Europe road-trip packing template data for the Flutter app."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any, Optional, Tuple

ROOT = Path(__file__).resolve().parents[1]
PACKING_JSON = ROOT / "assets" / "data" / "packing_templates.json"
L10N_DIR = ROOT / "lib" / "l10n"
ROAD_TRIP_DART = (
    ROOT
    / "lib"
    / "features"
    / "packing"
    / "presentation"
    / "localization"
    / "packing_template_localization_road_trip.dart"
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

LOCALES = ("en", "pl", "de", "hr", "cs", "sk", "hu")
ARB_FILES = {locale: L10N_DIR / f"app_{locale}.arb" for locale in LOCALES}

REUSED_ITEM_KEYS = {
    "packingTemplateItemIdentityDocument",
    "packingTemplateItemPassport",
    "packingTemplateItemDrivingLicense",
    "packingTemplateItemCarDocuments",
    "packingTemplateItemWallet",
    "packingTemplateItemPhoneCharger",
    "packingTemplateItemTravelAdapter",
    "packingTemplateItemMedicines",
    "packingTemplateItemFirstAidKit",
    "packingTemplateItemSnacks",
    "packingTemplateItemWaterBottle",
    "packingTemplateItemFuelCard",
    "packingTemplateItemHeadphones",
    "packingTemplateItemSunscreen",
    "packingTemplateItemRainJacket",
    "packingTemplateItemSunglasses",
    "packingTemplateItemToothbrush",
    "packingTemplateItemWarmLayers",
    "packingTemplateItemFlashlight",
}

TEMPLATE_TITLE: dict[str, str] = {
    "en": "Car travel",
    "pl": "Podróż samochodem",
    "de": "Autoreise",
    "hr": "Putovanje autom",
    "cs": "Cesta autem",
    "sk": "Cesta autom",
    "hu": "Autós utazás",
}

TEMPLATE_DESC: dict[str, str] = {
    "en": (
        "Comprehensive Europe road trip checklist: documents, route planning, "
        "vehicle checks, safety gear, and departure preparation"
    ),
    "pl": (
        "Kompleksowa lista na europejską podróż samochodem: dokumenty, plan trasy, "
        "kontrola pojazdu, sprzęt bezpieczeństwa i przygotowanie przed wyjazdem"
    ),
    "de": (
        "Umfassende Europa-Autoreise-Checkliste: Dokumente, Routenplanung, "
        "Fahrzeugchecks, Sicherheitsausrüstung und Abfahrtsvorbereitung"
    ),
    "hr": (
        "Sveobuhvatan popis za europsko cestovno putovanje: dokumenti, plan rute, "
        "provjera vozila, sigurnosna oprema i priprema prije polaska"
    ),
    "cs": (
        "Komplexní seznam na evropskou cestu autem: doklady, plánování trasy, "
        "kontrola vozidla, bezpečnostní vybavení a příprava před odjezdem"
    ),
    "sk": (
        "Komplexný zoznam na európsku cestu autom: doklady, plánovanie trasy, "
        "kontrola vozidla, bezpečnostné vybavenie a príprava pred odchodom"
    ),
    "hu": (
        "Átfogó európai autós út ellenőrzőlista: dokumentumok, útvonaltervezés, "
        "járműellenőrzés, biztonsági felszerelés és indulás előtti felkészülés"
    ),
}

NEW_CATEGORIES: dict[str, dict[str, str]] = {
    "packingTemplateCategoryRoutePreparation": {
        "en": "Route preparation",
        "pl": "Przygotowanie trasy",
        "de": "Routenplanung",
        "hr": "Priprema rute",
        "cs": "Příprava trasy",
        "sk": "Príprava trasy",
        "hu": "Útvonaltervezés",
    },
    "packingTemplateCategoryVehicleFluids": {
        "en": "Vehicle fluids",
        "pl": "Płyny eksploatacyjne",
        "de": "Fahrzeugflüssigkeiten",
        "hr": "Tekućine vozila",
        "cs": "Provozní kapaliny",
        "sk": "Prevádzkové kvapaliny",
        "hu": "Gépkocsifolyadékok",
    },
    "packingTemplateCategoryTyresBrakes": {
        "en": "Tyres and brakes",
        "pl": "Opony i hamulce",
        "de": "Reifen und Bremsen",
        "hr": "Gume i kočnice",
        "cs": "Pneumatiky a brzdy",
        "sk": "Pneumatiky a brzdy",
        "hu": "Gumiabroncsok és fékek",
    },
    "packingTemplateCategoryLightsVisibility": {
        "en": "Lights and visibility",
        "pl": "Oświetlenie i widoczność",
        "de": "Beleuchtung und Sichtbarkeit",
        "hr": "Svjetla i vidljivost",
        "cs": "Osvětlení a viditelnost",
        "sk": "Osvetlenie a viditeľnosť",
        "hu": "Világítás és láthatóság",
    },
    "packingTemplateCategorySafetyEquipment": {
        "en": "Safety equipment",
        "pl": "Wyposażenie bezpieczeństwa",
        "de": "Sicherheitsausrüstung",
        "hr": "Sigurnosna oprema",
        "cs": "Bezpečnostní vybavení",
        "sk": "Bezpečnostné vybavenie",
        "hu": "Biztonsági felszerelés",
    },
    "packingTemplateCategoryEmergencyTools": {
        "en": "Emergency tools",
        "pl": "Narzędzia awaryjne",
        "de": "Notfallwerkzeuge",
        "hr": "Alati za hitne slučajeve",
        "cs": "Nouzové nástroje",
        "sk": "Núdzové nástroje",
        "hu": "Vészhelyzeti eszközök",
    },
    "packingTemplateCategoryJourneyComfort": {
        "en": "Journey comfort",
        "pl": "Komfort w podróży",
        "de": "Reisekomfort",
        "hr": "Udobnost na putu",
        "cs": "Pohodlí na cestě",
        "sk": "Pohodlie na ceste",
        "hu": "Utazási kényelem",
    },
    "packingTemplateCategoryHomePreparation": {
        "en": "Home preparation",
        "pl": "Przygotowanie domu",
        "de": "Haushalt vorbereiten",
        "hr": "Priprema doma",
        "cs": "Příprava domácnosti",
        "sk": "Príprava domácnosti",
        "hu": "Otthon előkészítése",
    },
    "packingTemplateCategoryFinalDepartureChecks": {
        "en": "Final departure checks",
        "pl": "Ostatnie kontrole przed wyjazdem",
        "de": "Letzte Checks vor Abfahrt",
        "hr": "Završne provjere prije polaska",
        "cs": "Závěrečné kontroly před odjezdem",
        "sk": "Záverečné kontroly pred odchodom",
        "hu": "Utolsó ellenőrzések indulás előtt",
    },
}

# (id_suffix, nameKey, categoryKey, priority, needsPurchase, unitKey, noteKey?)
ItemSpec = Tuple[str, str, str, str, bool, str, Optional[str]]

ITEM_SPECS: list[ItemSpec] = [
    # Documents (14)
    ("identity", "packingTemplateItemIdentityDocument", "packingTemplateCategoryDocuments", "critical", False, "packingTemplateUnitPiece", None),
    ("passport", "packingTemplateItemPassport", "packingTemplateCategoryDocuments", "critical", False, "packingTemplateUnitPiece", None),
    ("driving_license", "packingTemplateItemDrivingLicense", "packingTemplateCategoryDocuments", "critical", False, "packingTemplateUnitPiece", None),
    ("car_documents", "packingTemplateItemCarDocuments", "packingTemplateCategoryDocuments", "critical", False, "packingTemplateUnitSet", None),
    ("wallet", "packingTemplateItemWallet", "packingTemplateCategoryDocuments", "important", False, "packingTemplateUnitPiece", None),
    ("vehicle_registration", "packingTemplateItemRtVehicleRegistration", "packingTemplateCategoryDocuments", "critical", False, "packingTemplateUnitPiece", None),
    ("insurance_proof", "packingTemplateItemRtInsuranceProof", "packingTemplateCategoryDocuments", "critical", False, "packingTemplateUnitPiece", None),
    ("green_card", "packingTemplateItemRtGreenCard", "packingTemplateCategoryDocuments", "important", False, "packingTemplateUnitPiece", None),
    ("roadside_assistance", "packingTemplateItemRtRoadsideAssistance", "packingTemplateCategoryDocuments", "important", False, "packingTemplateUnitPiece", None),
    ("vignette_receipts", "packingTemplateItemRtVignetteReceipts", "packingTemplateCategoryDocuments", "normal", False, "packingTemplateUnitSet", None),
    ("toll_badge", "packingTemplateItemRtTollBadge", "packingTemplateCategoryDocuments", "normal", True, "packingTemplateUnitPiece", None),
    ("travel_insurance", "packingTemplateItemRtTravelInsurance", "packingTemplateCategoryDocuments", "important", False, "packingTemplateUnitPiece", None),
    ("emergency_contacts", "packingTemplateItemRtEmergencyContacts", "packingTemplateCategoryDocuments", "important", False, "packingTemplateUnitSet", None),
    ("booking_confirmations", "packingTemplateItemRtBookingConfirmations", "packingTemplateCategoryDocuments", "normal", False, "packingTemplateUnitSet", None),
    # Route preparation (12)
    ("route_plan", "packingTemplateItemRtRoutePlan", "packingTemplateCategoryRoutePreparation", "critical", False, "packingTemplateUnitSet", None),
    ("offline_maps", "packingTemplateItemRtOfflineMaps", "packingTemplateCategoryRoutePreparation", "important", False, "packingTemplateUnitSet", None),
    ("border_crossing_info", "packingTemplateItemRtBorderCrossingInfo", "packingTemplateCategoryRoutePreparation", "important", False, "packingTemplateUnitSet", None),
    ("vignette_requirements", "packingTemplateItemRtVignetteRequirements", "packingTemplateCategoryRoutePreparation", "important", False, "packingTemplateUnitSet", None),
    ("toll_routes", "packingTemplateItemRtTollRoutes", "packingTemplateCategoryRoutePreparation", "normal", False, "packingTemplateUnitSet", None),
    ("parking_plan", "packingTemplateItemRtParkingPlan", "packingTemplateCategoryRoutePreparation", "normal", False, "packingTemplateUnitSet", None),
    ("rest_stops", "packingTemplateItemRtRestStops", "packingTemplateCategoryRoutePreparation", "normal", False, "packingTemplateUnitSet", None),
    ("fuel_plan", "packingTemplateItemRtFuelPlan", "packingTemplateCategoryRoutePreparation", "important", False, "packingTemplateUnitSet", None),
    ("alternative_routes", "packingTemplateItemRtAlternativeRoutes", "packingTemplateCategoryRoutePreparation", "normal", False, "packingTemplateUnitSet", None),
    ("traffic_rules", "packingTemplateItemRtTrafficRules", "packingTemplateCategoryRoutePreparation", "important", False, "packingTemplateUnitSet", None),
    ("emergency_numbers", "packingTemplateItemRtEmergencyNumbers", "packingTemplateCategoryRoutePreparation", "important", False, "packingTemplateUnitSet", None),
    ("payment_ready", "packingTemplateItemRtPaymentReady", "packingTemplateCategoryRoutePreparation", "important", False, "packingTemplateUnitSet", None),
    # Vehicle fluids (9)
    ("engine_oil_check", "packingTemplateItemRtEngineOilCheck", "packingTemplateCategoryVehicleFluids", "critical", False, "packingTemplateUnitSet", None),
    ("coolant_check", "packingTemplateItemRtCoolantCheck", "packingTemplateCategoryVehicleFluids", "important", False, "packingTemplateUnitSet", None),
    ("brake_fluid_check", "packingTemplateItemRtBrakeFluidCheck", "packingTemplateCategoryVehicleFluids", "important", False, "packingTemplateUnitSet", None),
    ("washer_fluid", "packingTemplateItemRtWasherFluid", "packingTemplateCategoryVehicleFluids", "normal", False, "packingTemplateUnitSet", None),
    ("adblue", "packingTemplateItemRtAdBlue", "packingTemplateCategoryVehicleFluids", "normal", False, "packingTemplateUnitPack", None),
    ("spare_engine_oil", "packingTemplateItemRtSpareEngineOil", "packingTemplateCategoryVehicleFluids", "normal", True, "packingTemplateUnitPack", None),
    ("spare_coolant", "packingTemplateItemRtSpareCoolant", "packingTemplateCategoryVehicleFluids", "normal", True, "packingTemplateUnitPack", None),
    ("spare_washer_fluid", "packingTemplateItemRtSpareWasherFluid", "packingTemplateCategoryVehicleFluids", "normal", True, "packingTemplateUnitPack", None),
    # Tyres/brakes (10)
    ("tyre_pressure", "packingTemplateItemRtTyrePressure", "packingTemplateCategoryTyresBrakes", "critical", False, "packingTemplateUnitSet", None),
    ("spare_tyre", "packingTemplateItemRtSpareTyre", "packingTemplateCategoryTyresBrakes", "important", False, "packingTemplateUnitPiece", None),
    ("tyre_tread", "packingTemplateItemRtTyreTread", "packingTemplateCategoryTyresBrakes", "important", False, "packingTemplateUnitSet", None),
    ("wheel_wrench", "packingTemplateItemRtWheelWrench", "packingTemplateCategoryTyresBrakes", "important", False, "packingTemplateUnitPiece", None),
    ("jack", "packingTemplateItemRtJack", "packingTemplateCategoryTyresBrakes", "important", False, "packingTemplateUnitPiece", None),
    ("brake_pads_check", "packingTemplateItemRtBrakePadsCheck", "packingTemplateCategoryTyresBrakes", "important", False, "packingTemplateUnitSet", None),
    ("tyre_inflator", "packingTemplateItemRtTyreInflator", "packingTemplateCategoryTyresBrakes", "normal", True, "packingTemplateUnitPiece", None),
    ("tyre_repair_spray", "packingTemplateItemRtTyreRepairSpray", "packingTemplateCategoryTyresBrakes", "normal", True, "packingTemplateUnitPack", None),
    ("wheel_chocks", "packingTemplateItemRtWheelChocks", "packingTemplateCategoryTyresBrakes", "normal", False, "packingTemplateUnitPair", None),
    # Lights (10)
    ("exterior_lights", "packingTemplateItemRtExteriorLightsCheck", "packingTemplateCategoryLightsVisibility", "critical", False, "packingTemplateUnitSet", None),
    ("spare_headlight_bulbs", "packingTemplateItemRtSpareHeadlightBulbs", "packingTemplateCategoryLightsVisibility", "normal", True, "packingTemplateUnitSet", None),
    ("rear_lights_check", "packingTemplateItemRtRearLightsCheck", "packingTemplateCategoryLightsVisibility", "important", False, "packingTemplateUnitSet", None),
    ("indicators_check", "packingTemplateItemRtIndicatorsCheck", "packingTemplateCategoryLightsVisibility", "important", False, "packingTemplateUnitSet", None),
    ("brake_lights_check", "packingTemplateItemRtBrakeLightsCheck", "packingTemplateCategoryLightsVisibility", "important", False, "packingTemplateUnitSet", None),
    ("high_vis_vest", "packingTemplateItemRtHighVisVest", "packingTemplateCategoryLightsVisibility", "critical", False, "packingTemplateUnitPiece", None),
    ("warning_triangle", "packingTemplateItemRtWarningTriangle", "packingTemplateCategoryLightsVisibility", "critical", False, "packingTemplateUnitPiece", None),
    ("headlight_beam_adjust", "packingTemplateItemRtHeadlightBeamAdjust", "packingTemplateCategoryLightsVisibility", "important", False, "packingTemplateUnitSet", None),
    ("light_cleaning_kit", "packingTemplateItemRtLightCleaningKit", "packingTemplateCategoryLightsVisibility", "normal", False, "packingTemplateUnitSet", None),
    # Safety equipment (9)
    ("first_aid", "packingTemplateItemFirstAidKit", "packingTemplateCategorySafetyEquipment", "critical", False, "packingTemplateUnitSet", None),
    ("fire_extinguisher", "packingTemplateItemRtFireExtinguisher", "packingTemplateCategorySafetyEquipment", "important", False, "packingTemplateUnitPiece", None),
    ("high_vis_vests_set", "packingTemplateItemRtHighVisVestsSet", "packingTemplateCategorySafetyEquipment", "critical", False, "packingTemplateUnitSet", None),
    ("seat_belt_cutter", "packingTemplateItemRtSeatBeltCutter", "packingTemplateCategorySafetyEquipment", "normal", True, "packingTemplateUnitPiece", None),
    ("emergency_blanket", "packingTemplateItemRtEmergencyBlanket", "packingTemplateCategorySafetyEquipment", "normal", False, "packingTemplateUnitPiece", None),
    ("breathalyzer", "packingTemplateItemRtBreathalyzer", "packingTemplateCategorySafetyEquipment", "normal", True, "packingTemplateUnitPiece", None),
    ("snow_chains", "packingTemplateItemRtSnowChains", "packingTemplateCategorySafetyEquipment", "normal", True, "packingTemplateUnitSet", None),
    ("dash_cam", "packingTemplateItemRtDashCam", "packingTemplateCategorySafetyEquipment", "normal", True, "packingTemplateUnitPiece", None),
    # Emergency tools (10)
    ("jump_leads", "packingTemplateItemRtJumpLeads", "packingTemplateCategoryEmergencyTools", "important", False, "packingTemplateUnitSet", None),
    ("multi_tool", "packingTemplateItemRtMultiTool", "packingTemplateCategoryEmergencyTools", "normal", False, "packingTemplateUnitPiece", None),
    ("puncture_kit", "packingTemplateItemRtPunctureKit", "packingTemplateCategoryEmergencyTools", "important", False, "packingTemplateUnitSet", None),
    ("duct_tape", "packingTemplateItemRtDuctTape", "packingTemplateCategoryEmergencyTools", "normal", False, "packingTemplateUnitPack", None),
    ("work_gloves", "packingTemplateItemRtWorkGloves", "packingTemplateCategoryEmergencyTools", "normal", False, "packingTemplateUnitPair", None),
    ("flashlight", "packingTemplateItemFlashlight", "packingTemplateCategoryEmergencyTools", "important", False, "packingTemplateUnitPiece", None),
    ("portable_jump_starter", "packingTemplateItemRtPortableJumpStarter", "packingTemplateCategoryEmergencyTools", "normal", True, "packingTemplateUnitPiece", None),
    # Electronics (12)
    ("phone_charger", "packingTemplateItemPhoneCharger", "packingTemplateCategoryElectronics", "critical", False, "packingTemplateUnitPiece", None),
    ("travel_adapter", "packingTemplateItemTravelAdapter", "packingTemplateCategoryElectronics", "important", True, "packingTemplateUnitPiece", None),
    ("headphones", "packingTemplateItemHeadphones", "packingTemplateCategoryElectronics", "normal", False, "packingTemplateUnitPiece", None),
    ("fuel_card", "packingTemplateItemFuelCard", "packingTemplateCategoryElectronics", "important", False, "packingTemplateUnitPiece", None),
    ("car_phone_mount", "packingTemplateItemRtCarPhoneMount", "packingTemplateCategoryElectronics", "important", True, "packingTemplateUnitPiece", None),
    ("usb_car_charger", "packingTemplateItemRtUsbCarCharger", "packingTemplateCategoryElectronics", "important", True, "packingTemplateUnitPiece", None),
    ("portable_power_bank", "packingTemplateItemRtPortablePowerBank", "packingTemplateCategoryElectronics", "important", True, "packingTemplateUnitPiece", None),
    ("gps_navigation", "packingTemplateItemRtGpsNavigation", "packingTemplateCategoryElectronics", "important", False, "packingTemplateUnitPiece", None),
    ("bluetooth_handsfree", "packingTemplateItemRtBluetoothHandsfree", "packingTemplateCategoryElectronics", "important", False, "packingTemplateUnitPiece", None),
    ("dash_cam_sd", "packingTemplateItemRtDashCamSdCard", "packingTemplateCategoryElectronics", "normal", True, "packingTemplateUnitPiece", None),
    ("charging_cables", "packingTemplateItemRtChargingCables", "packingTemplateCategoryElectronics", "normal", False, "packingTemplateUnitSet", None),
    # Health (13)
    ("medicines", "packingTemplateItemMedicines", "packingTemplateCategoryHealth", "critical", False, "packingTemplateUnitPack", "packingTemplateNotePrescriptionMeds"),
    ("motion_sickness", "packingTemplateItemRtMotionSickness", "packingTemplateCategoryHealth", "normal", False, "packingTemplateUnitPack", None),
    ("pain_relievers", "packingTemplateItemRtPainRelievers", "packingTemplateCategoryHealth", "normal", False, "packingTemplateUnitPack", None),
    ("allergy_meds", "packingTemplateItemRtAllergyMeds", "packingTemplateCategoryHealth", "normal", False, "packingTemplateUnitPack", None),
    ("sunscreen", "packingTemplateItemSunscreen", "packingTemplateCategoryHealth", "normal", True, "packingTemplateUnitPack", None),
    ("hand_sanitizer", "packingTemplateItemRtHandSanitizer", "packingTemplateCategoryHealth", "normal", False, "packingTemplateUnitPack", None),
    ("insect_repellent", "packingTemplateItemRtInsectRepellent", "packingTemplateCategoryHealth", "normal", True, "packingTemplateUnitPack", None),
    ("bandages", "packingTemplateItemRtBandages", "packingTemplateCategoryHealth", "normal", False, "packingTemplateUnitPack", None),
    ("antiseptic_wipes", "packingTemplateItemRtAntisepticWipes", "packingTemplateCategoryHealth", "normal", False, "packingTemplateUnitPack", None),
    ("travel_sickness_bags", "packingTemplateItemRtTravelSicknessBags", "packingTemplateCategoryHealth", "normal", False, "packingTemplateUnitPack", None),
    ("eye_drops", "packingTemplateItemRtEyeDrops", "packingTemplateCategoryHealth", "normal", False, "packingTemplateUnitPack", None),
    ("health_insurance_card", "packingTemplateItemRtHealthInsuranceCard", "packingTemplateCategoryHealth", "important", False, "packingTemplateUnitPiece", None),
    # Food (10)
    ("snacks", "packingTemplateItemSnacks", "packingTemplateCategoryFood", "normal", False, "packingTemplateUnitPack", None),
    ("water_bottle", "packingTemplateItemWaterBottle", "packingTemplateCategoryFood", "important", False, "packingTemplateUnitPiece", None),
    ("cool_bag", "packingTemplateItemRtCoolBag", "packingTemplateCategoryFood", "normal", True, "packingTemplateUnitPiece", None),
    ("thermos_flask", "packingTemplateItemRtThermosFlask", "packingTemplateCategoryFood", "normal", False, "packingTemplateUnitPiece", None),
    ("non_perishable_food", "packingTemplateItemRtNonPerishableFood", "packingTemplateCategoryFood", "normal", False, "packingTemplateUnitPack", None),
    ("travel_mugs", "packingTemplateItemRtTravelMugs", "packingTemplateCategoryFood", "normal", False, "packingTemplateUnitPair", None),
    ("reusable_cutlery", "packingTemplateItemRtReusableCutlery", "packingTemplateCategoryFood", "normal", False, "packingTemplateUnitSet", None),
    ("wet_wipes_food", "packingTemplateItemRtWetWipesFood", "packingTemplateCategoryFood", "normal", False, "packingTemplateUnitPack", None),
    ("coffee_tea", "packingTemplateItemRtCoffeeTea", "packingTemplateCategoryFood", "normal", False, "packingTemplateUnitPack", None),
    # Journey comfort (10)
    ("neck_pillow", "packingTemplateItemRtNeckPillow", "packingTemplateCategoryJourneyComfort", "normal", True, "packingTemplateUnitPiece", None),
    ("travel_blanket", "packingTemplateItemRtTravelBlanket", "packingTemplateCategoryJourneyComfort", "normal", False, "packingTemplateUnitPiece", None),
    ("sunglasses", "packingTemplateItemSunglasses", "packingTemplateCategoryJourneyComfort", "normal", False, "packingTemplateUnitPiece", None),
    ("sun_shade", "packingTemplateItemRtSunShade", "packingTemplateCategoryJourneyComfort", "normal", True, "packingTemplateUnitPiece", None),
    ("trash_bags", "packingTemplateItemRtTrashBags", "packingTemplateCategoryJourneyComfort", "normal", False, "packingTemplateUnitPack", None),
    ("passenger_entertainment", "packingTemplateItemRtPassengerEntertainment", "packingTemplateCategoryJourneyComfort", "normal", False, "packingTemplateUnitSet", None),
    ("audiobooks", "packingTemplateItemRtAudiobooks", "packingTemplateCategoryJourneyComfort", "normal", False, "packingTemplateUnitSet", None),
    ("comfort_cushion", "packingTemplateItemRtComfortCushion", "packingTemplateCategoryJourneyComfort", "normal", False, "packingTemplateUnitPiece", None),
    ("air_freshener", "packingTemplateItemRtAirFreshener", "packingTemplateCategoryJourneyComfort", "normal", False, "packingTemplateUnitPiece", None),
    # Clothing (6)
    ("warm_layers", "packingTemplateItemWarmLayers", "packingTemplateCategoryClothing", "important", False, "packingTemplateUnitSet", None),
    ("rain_jacket", "packingTemplateItemRainJacket", "packingTemplateCategoryClothing", "important", False, "packingTemplateUnitPiece", None),
    ("comfortable_shoes", "packingTemplateItemRtComfortableShoes", "packingTemplateCategoryClothing", "important", False, "packingTemplateUnitPair", None),
    ("change_of_clothes", "packingTemplateItemRtChangeOfClothes", "packingTemplateCategoryClothing", "normal", False, "packingTemplateUnitSet", None),
    ("hat_cap", "packingTemplateItemRtHatCap", "packingTemplateCategoryClothing", "normal", False, "packingTemplateUnitPiece", None),
    # Toiletries (7)
    ("toothbrush", "packingTemplateItemToothbrush", "packingTemplateCategoryToiletries", "normal", False, "packingTemplateUnitPiece", None),
    ("toothpaste", "packingTemplateItemRtToothpaste", "packingTemplateCategoryToiletries", "normal", False, "packingTemplateUnitPack", None),
    ("deodorant", "packingTemplateItemRtDeodorant", "packingTemplateCategoryToiletries", "normal", False, "packingTemplateUnitPiece", None),
    ("tissues", "packingTemplateItemRtTissues", "packingTemplateCategoryToiletries", "normal", False, "packingTemplateUnitPack", None),
    ("lip_balm", "packingTemplateItemRtLipBalm", "packingTemplateCategoryToiletries", "normal", False, "packingTemplateUnitPiece", None),
    ("hand_soap", "packingTemplateItemRtHandSoap", "packingTemplateCategoryToiletries", "normal", False, "packingTemplateUnitPack", None),
    ("shower_gel", "packingTemplateItemRtShowerGel", "packingTemplateCategoryToiletries", "normal", False, "packingTemplateUnitPack", None),
    # Home prep (10)
    ("unplug_appliances", "packingTemplateItemRtUnplugAppliances", "packingTemplateCategoryHomePreparation", "important", False, "packingTemplateUnitSet", None),
    ("set_heating_water", "packingTemplateItemRtSetHeatingWater", "packingTemplateCategoryHomePreparation", "important", False, "packingTemplateUnitSet", None),
    ("secure_home", "packingTemplateItemRtSecureHome", "packingTemplateCategoryHomePreparation", "critical", False, "packingTemplateUnitSet", None),
    ("pet_mail_care", "packingTemplateItemRtPetMailCare", "packingTemplateCategoryHomePreparation", "important", False, "packingTemplateUnitSet", None),
    ("spare_house_key", "packingTemplateItemRtSpareHouseKey", "packingTemplateCategoryHomePreparation", "normal", False, "packingTemplateUnitPiece", None),
    ("security_alarm", "packingTemplateItemRtSecurityAlarm", "packingTemplateCategoryHomePreparation", "important", False, "packingTemplateUnitSet", None),
    ("take_out_trash", "packingTemplateItemRtTakeOutTrash", "packingTemplateCategoryHomePreparation", "normal", False, "packingTemplateUnitSet", None),
    ("utility_shutoff", "packingTemplateItemRtUtilityShutoff", "packingTemplateCategoryHomePreparation", "important", False, "packingTemplateUnitSet", None),
    ("notify_neighbor", "packingTemplateItemRtNotifyNeighbor", "packingTemplateCategoryHomePreparation", "normal", False, "packingTemplateUnitSet", None),
    ("timer_lights", "packingTemplateItemRtTimerLights", "packingTemplateCategoryHomePreparation", "normal", False, "packingTemplateUnitSet", None),
    # Final checks (10)
    ("fuel_tank_full", "packingTemplateItemRtFuelTankFull", "packingTemplateCategoryFinalDepartureChecks", "critical", False, "packingTemplateUnitSet", None),
    ("tyres_recheck", "packingTemplateItemRtTyresRecheck", "packingTemplateCategoryFinalDepartureChecks", "critical", False, "packingTemplateUnitSet", None),
    ("documents_in_car", "packingTemplateItemRtDocumentsInCar", "packingTemplateCategoryFinalDepartureChecks", "critical", False, "packingTemplateUnitSet", None),
    ("phone_charged", "packingTemplateItemRtPhoneCharged", "packingTemplateCategoryFinalDepartureChecks", "critical", False, "packingTemplateUnitSet", None),
    ("navigation_set", "packingTemplateItemRtNavigationSet", "packingTemplateCategoryFinalDepartureChecks", "important", False, "packingTemplateUnitSet", None),
    ("emergency_kit_accessible", "packingTemplateItemRtEmergencyKitAccessible", "packingTemplateCategoryFinalDepartureChecks", "important", False, "packingTemplateUnitSet", None),
    ("snacks_loaded", "packingTemplateItemRtSnacksLoaded", "packingTemplateCategoryFinalDepartureChecks", "normal", False, "packingTemplateUnitSet", None),
    ("car_cleaned", "packingTemplateItemRtCarCleaned", "packingTemplateCategoryFinalDepartureChecks", "normal", False, "packingTemplateUnitSet", None),
    ("mirrors_adjusted", "packingTemplateItemRtMirrorsAdjusted", "packingTemplateCategoryFinalDepartureChecks", "important", False, "packingTemplateUnitSet", None),
    ("departure_time_set", "packingTemplateItemRtDepartureTimeSet", "packingTemplateCategoryFinalDepartureChecks", "important", False, "packingTemplateUnitSet", None),
]

from road_trip_translations import NEW_ITEM_TRANSLATIONS  # noqa: E402


def build_items() -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []
    for sort_order, spec in enumerate(ITEM_SPECS):
        suffix, name_key, category_key, priority, needs_purchase, unit_key, note_key = spec
        item: dict[str, Any] = {
            "id": f"rt_{suffix}",
            "nameKey": name_key,
            "categoryKey": category_key,
            "quantity": 1,
            "unitKey": unit_key,
            "priority": priority,
            "sortOrder": sort_order,
        }
        if needs_purchase:
            item["needsPurchase"] = True
        if note_key:
            item["noteKey"] = note_key
        items.append(item)
    return items


def collect_new_keys() -> tuple[set[str], set[str]]:
    category_keys = set(NEW_CATEGORIES)
    item_keys = {
        spec[1]
        for spec in ITEM_SPECS
        if spec[1].startswith("packingTemplateItemRt")
    }
    missing = item_keys - set(NEW_ITEM_TRANSLATIONS)
    if missing:
        raise ValueError(f"Missing translations for: {sorted(missing)}")
    return category_keys, item_keys


def build_arb_entries(locale: str) -> dict[str, str]:
    entries: dict[str, str] = {
        "packingTemplateCarTravel": TEMPLATE_TITLE[locale],
        "packingTemplateCarTravelDesc": TEMPLATE_DESC[locale],
    }
    for key, translations in NEW_CATEGORIES.items():
        entries[key] = translations[locale]
    for key, translations in NEW_ITEM_TRANSLATIONS.items():
        entries[key] = translations[locale]
    return entries


def key_to_dart_property(key: str) -> str:
    return key[0].lower() + key[1:]


def generate_dart_switch_cases(keys: list[str]) -> str:
    lines = []
    for key in sorted(keys):
        prop = key_to_dart_property(key)
        lines.append(f"    case '{key}':")
        lines.append(f"      return l10n.{prop};")
    return "\n".join(lines)


def generate_road_trip_dart(keys: list[str]) -> str:
    switch_body = generate_dart_switch_cases(keys)
    return f"""import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Extended resolver for Europe road-trip packing template keys.
String? resolveRoadTripPackingTemplateKey(AppLocalizations l10n, String key) {{
  switch (key) {{
{switch_body}
    default:
      return null;
  }}
}}
"""


def load_arb(path: Path) -> tuple[dict[str, Any], list[str]]:
    text = path.read_text(encoding="utf-8")
    data = json.loads(text)
    metadata_keys = [k for k in data if k.startswith("@")]
    return data, metadata_keys


def merge_arb_file(path: Path, new_entries: dict[str, str]) -> None:
    data, _ = load_arb(path)
    locale = path.stem.replace("app_", "")
    entries = build_arb_entries(locale)
    for key, value in entries.items():
        data[key] = value
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def update_packing_templates(items: list[dict[str, Any]]) -> None:
    templates = json.loads(PACKING_JSON.read_text(encoding="utf-8"))
    updated = False
    for template in templates:
        if template.get("id") == "sys_tpl_car_travel":
            template["items"] = items
            updated = True
            break
    if not updated:
        raise ValueError("sys_tpl_car_travel template not found")
    PACKING_JSON.write_text(
        json.dumps(templates, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def update_main_localization_dart() -> None:
    text = MAIN_DART.read_text(encoding="utf-8")
    import_line = (
        "import 'package:travel_cost_planner_europe/features/packing/presentation/"
        "localization/packing_template_localization_road_trip.dart';\n"
    )
    if import_line not in text:
        text = text.replace(
            "import 'package:flutter_gen/gen_l10n/app_localizations.dart';\n",
            "import 'package:flutter_gen/gen_l10n/app_localizations.dart';\n"
            + import_line,
        )
    if "resolveRoadTripPackingTemplateKey" not in text:
        text = text.replace(
            "String resolvePackingTemplateKey(AppLocalizations l10n, String key) {\n"
            "  switch (key) {",
            "String resolvePackingTemplateKey(AppLocalizations l10n, String key) {\n"
            "  final roadTrip = resolveRoadTripPackingTemplateKey(l10n, key);\n"
            "  if (roadTrip != null) {\n"
            "    return roadTrip;\n"
            "  }\n\n"
            "  switch (key) {",
        )
    MAIN_DART.write_text(text, encoding="utf-8")


def apply_changes(items: list[dict[str, Any]], dart_keys: list[str]) -> None:
    update_packing_templates(items)
    for path in ARB_FILES.values():
        merge_arb_file(path, {})
    ROAD_TRIP_DART.parent.mkdir(parents=True, exist_ok=True)
    ROAD_TRIP_DART.write_text(generate_road_trip_dart(dart_keys), encoding="utf-8")
    update_main_localization_dart()


def print_summary(items: list[dict[str, Any]], category_keys: set[str], item_keys: set[str]) -> None:
    categories_used = {spec[2] for spec in ITEM_SPECS}
    print(f"Items: {len(items)}")
    print(f"Categories used: {len(categories_used)}")
    print(f"New category keys: {len(category_keys)}")
    print(f"New item keys: {len(item_keys)}")
    print(f"Total new l10n keys: {len(category_keys) + len(item_keys) + 2}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Write generated data into the Flutter project",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        help="Optional directory for generated artifacts",
    )
    args = parser.parse_args()

    items = build_items()
    category_keys, item_keys = collect_new_keys()
    dart_keys = sorted(category_keys | item_keys)

    if args.output_dir:
        args.output_dir.mkdir(parents=True, exist_ok=True)
        (args.output_dir / "car_travel_items.json").write_text(
            json.dumps(items, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        for locale, path in ARB_FILES.items():
            snippet = build_arb_entries(locale)
            (args.output_dir / f"arb_{locale}.json").write_text(
                json.dumps(snippet, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
        (args.output_dir / "road_trip_localization.dart").write_text(
            generate_road_trip_dart(dart_keys),
            encoding="utf-8",
        )

    print(json.dumps(items, ensure_ascii=False, indent=2))
    print("\n--- ARB snippet (en) ---\n")
    print(json.dumps(build_arb_entries("en"), ensure_ascii=False, indent=2))
    print("\n--- Dart switch cases ---\n")
    print(generate_dart_switch_cases(dart_keys))
    print_summary(items, category_keys, item_keys)

    if args.apply:
        apply_changes(items, dart_keys)
        print("\nApplied changes to project files.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
