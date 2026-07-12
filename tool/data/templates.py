"""Template item specifications for the modular packing library."""

from __future__ import annotations

from typing import Any, Optional

ItemSpec = tuple[str, str, str, str, bool, str, Optional[str]]

UNIT_PIECE = "packingTemplateUnitPiece"
UNIT_PAIR = "packingTemplateUnitPair"
UNIT_SET = "packingTemplateUnitSet"
UNIT_PACK = "packingTemplateUnitPack"

CAT_DOCS = "packingTemplateCategoryDocuments"
CAT_CLOTH = "packingTemplateCategoryClothing"
CAT_TOILET = "packingTemplateCategoryToiletries"
CAT_ELEC = "packingTemplateCategoryElectronics"
CAT_HEALTH = "packingTemplateCategoryHealth"
CAT_FOOD = "packingTemplateCategoryFood"
CAT_HOME = "packingTemplateCategoryHomePreparation"
CAT_FINAL = "packingTemplateCategoryFinalDepartureChecks"
CAT_ROUTE = "packingTemplateCategoryRoutePreparation"
CAT_FLUIDS = "packingTemplateCategoryVehicleFluids"
CAT_TYRES = "packingTemplateCategoryTyresBrakes"
CAT_LIGHTS = "packingTemplateCategoryLightsVisibility"
CAT_SAFETY = "packingTemplateCategorySafetyEquipment"
CAT_EMERG = "packingTemplateCategoryEmergencyTools"
CAT_LUGGAGE = "packingTemplateCategoryLuggageLoading"
CAT_SUMMER = "packingTemplateCategorySummerGear"
CAT_WINTER = "packingTemplateCategoryWinterGear"
CAT_MOTO = "packingTemplateCategoryMotorcycleGear"
CAT_BIKE = "packingTemplateCategoryBicycleGear"
CAT_CAMPER = "packingTemplateCategoryCamperGear"
CAT_BABY = "packingTemplateCategoryBabyCare"
CAT_CAT = "packingTemplateCategoryCatCare"
CAT_CHILD = "packingTemplateCategoryChildCare"
CAT_PET = "packingTemplateCategoryPetCare"
CAT_BEACH = "packingTemplateCategoryBeachGear"
CAT_OUTDOOR = "packingTemplateCategoryOutdoor"
CAT_TRAVEL = "packingTemplateCategoryTravelGear"
CAT_BUSINESS = "packingTemplateCategoryBusiness"

GROUP_TRANSPORT = "packingTemplateGroupTransport"
GROUP_ESSENTIALS = "packingTemplateGroupEssentials"
GROUP_TRIP_TYPE = "packingTemplateGroupTripType"
GROUP_TRAVELLERS = "packingTemplateGroupTravellers"
GROUP_BEFORE_LEAVING = "packingTemplateGroupBeforeLeaving"


def _i(
    suffix: str,
    name_key: str,
    category_key: str,
    priority: str = "normal",
    needs_purchase: bool = False,
    unit_key: str = UNIT_PIECE,
    note_key: Optional[str] = None,
) -> ItemSpec:
    return (suffix, name_key, category_key, priority, needs_purchase, unit_key, note_key)


ROAD_TRIP_SPECS: list[ItemSpec] = [
    _i("driving_license", "packingTemplateItemDrivingLicense", CAT_DOCS, "critical"),
    _i("car_documents", "packingTemplateItemCarDocuments", CAT_DOCS, "critical", unit_key=UNIT_SET),
    _i("vehicle_registration", "packingTemplateItemRtVehicleRegistration", CAT_DOCS, "critical"),
    _i("insurance_proof", "packingTemplateItemRtInsuranceProof", CAT_DOCS, "critical"),
    _i("green_card", "packingTemplateItemRtGreenCard", CAT_DOCS, "important"),
    _i("roadside_assistance", "packingTemplateItemRtRoadsideAssistance", CAT_DOCS, "important"),
    _i("vignette_receipts", "packingTemplateItemRtVignetteReceipts", CAT_DOCS, unit_key=UNIT_SET),
    _i("toll_badge", "packingTemplateItemRtTollBadge", CAT_DOCS, needs_purchase=True),
    _i("route_plan", "packingTemplateItemRtRoutePlan", CAT_ROUTE, "critical", unit_key=UNIT_SET),
    _i("offline_maps", "packingTemplateItemRtOfflineMaps", CAT_ROUTE, "important", unit_key=UNIT_SET),
    _i("border_crossing_info", "packingTemplateItemRtBorderCrossingInfo", CAT_ROUTE, "important", unit_key=UNIT_SET),
    _i("vignette_requirements", "packingTemplateItemRtVignetteRequirements", CAT_ROUTE, "important", unit_key=UNIT_SET),
    _i("toll_routes", "packingTemplateItemRtTollRoutes", CAT_ROUTE, unit_key=UNIT_SET),
    _i("rest_stops", "packingTemplateItemRtRestStops", CAT_ROUTE, unit_key=UNIT_SET),
    _i("fuel_plan", "packingTemplateItemRtFuelPlan", CAT_ROUTE, "important", unit_key=UNIT_SET),
    _i("traffic_rules", "packingTemplateItemRtTrafficRules", CAT_ROUTE, "important", unit_key=UNIT_SET),
    _i("emergency_numbers", "packingTemplateItemRtEmergencyNumbers", CAT_ROUTE, "important", unit_key=UNIT_SET),
    _i("engine_oil_check", "packingTemplateItemRtEngineOilCheck", CAT_FLUIDS, "critical", unit_key=UNIT_SET),
    _i("coolant_check", "packingTemplateItemRtCoolantCheck", CAT_FLUIDS, "important", unit_key=UNIT_SET),
    _i("brake_fluid_check", "packingTemplateItemRtBrakeFluidCheck", CAT_FLUIDS, "important", unit_key=UNIT_SET),
    _i("washer_fluid", "packingTemplateItemRtWasherFluid", CAT_FLUIDS, unit_key=UNIT_SET),
    _i("adblue", "packingTemplateItemRtAdBlue", CAT_FLUIDS, unit_key=UNIT_PACK),
    _i("tyre_pressure", "packingTemplateItemRtTyrePressure", CAT_TYRES, "critical", unit_key=UNIT_SET),
    _i("spare_tyre", "packingTemplateItemRtSpareTyre", CAT_TYRES, "important"),
    _i("tyre_tread", "packingTemplateItemRtTyreTread", CAT_TYRES, "important", unit_key=UNIT_SET),
    _i("wheel_wrench", "packingTemplateItemRtWheelWrench", CAT_TYRES, "important"),
    _i("jack", "packingTemplateItemRtJack", CAT_TYRES, "important"),
    _i("brake_pads_check", "packingTemplateItemRtBrakePadsCheck", CAT_TYRES, "important", unit_key=UNIT_SET),
    _i("tyre_inflator", "packingTemplateItemRtTyreInflator", CAT_TYRES, needs_purchase=True),
    _i("exterior_lights", "packingTemplateItemRtExteriorLightsCheck", CAT_LIGHTS, "critical", unit_key=UNIT_SET),
    _i("spare_headlight_bulbs", "packingTemplateItemRtSpareHeadlightBulbs", CAT_LIGHTS, needs_purchase=True, unit_key=UNIT_SET),
    _i("rear_lights_check", "packingTemplateItemRtRearLightsCheck", CAT_LIGHTS, "important", unit_key=UNIT_SET),
    _i("indicators_check", "packingTemplateItemRtIndicatorsCheck", CAT_LIGHTS, "important", unit_key=UNIT_SET),
    _i("brake_lights_check", "packingTemplateItemRtBrakeLightsCheck", CAT_LIGHTS, "important", unit_key=UNIT_SET),
    _i("high_vis_vest", "packingTemplateItemRtHighVisVest", CAT_LIGHTS, "critical"),
    _i("warning_triangle", "packingTemplateItemRtWarningTriangle", CAT_LIGHTS, "critical"),
    _i("headlight_beam_adjust", "packingTemplateItemRtHeadlightBeamAdjust", CAT_LIGHTS, "important", unit_key=UNIT_SET),
    _i("first_aid", "packingTemplateItemFirstAidKit", CAT_SAFETY, "critical", unit_key=UNIT_SET),
    _i("fire_extinguisher", "packingTemplateItemRtFireExtinguisher", CAT_SAFETY, "important"),
    _i("high_vis_vests_set", "packingTemplateItemRtHighVisVestsSet", CAT_SAFETY, "critical", unit_key=UNIT_SET),
    _i("emergency_blanket", "packingTemplateItemRtEmergencyBlanket", CAT_SAFETY),
    _i("snow_chains", "packingTemplateItemRtSnowChains", CAT_SAFETY, needs_purchase=True, unit_key=UNIT_SET),
    _i("jump_leads", "packingTemplateItemRtJumpLeads", CAT_EMERG, "important", unit_key=UNIT_SET),
    _i("multi_tool", "packingTemplateItemRtMultiTool", CAT_EMERG),
    _i("puncture_kit", "packingTemplateItemRtPunctureKit", CAT_EMERG, "important", unit_key=UNIT_SET),
    _i("duct_tape", "packingTemplateItemRtDuctTape", CAT_EMERG, unit_key=UNIT_PACK),
    _i("work_gloves", "packingTemplateItemRtWorkGloves", CAT_EMERG, unit_key=UNIT_PAIR),
    _i("flashlight", "packingTemplateItemFlashlight", CAT_EMERG, "important"),
    _i("roadside_kit", "packingTemplateItemRoadsideKit", CAT_EMERG, "important", unit_key=UNIT_SET),
    _i("portable_jump_starter", "packingTemplateItemRtPortableJumpStarter", CAT_EMERG, needs_purchase=True),
    _i("fuel_card", "packingTemplateItemFuelCard", CAT_ELEC, "important"),
    _i("car_phone_mount", "packingTemplateItemRtCarPhoneMount", CAT_ELEC, "important", needs_purchase=True),
    _i("usb_car_charger", "packingTemplateItemRtUsbCarCharger", CAT_ELEC, "important", needs_purchase=True),
    _i("gps_navigation", "packingTemplateItemRtGpsNavigation", CAT_ELEC, "important"),
    _i("bluetooth_handsfree", "packingTemplateItemRtBluetoothHandsfree", CAT_ELEC, "important"),
    _i("dash_cam_sd", "packingTemplateItemRtDashCamSdCard", CAT_ELEC, needs_purchase=True),
    _i("dash_cam", "packingTemplateItemRtDashCam", CAT_ELEC, needs_purchase=True),
    _i("charging_cables", "packingTemplateItemRtChargingCables", CAT_ELEC, unit_key=UNIT_SET),
    _i("roof_box_secured", "packingTemplateItemRtRoofBoxSecured", CAT_LUGGAGE, "important", unit_key=UNIT_SET),
    _i("luggage_loaded", "packingTemplateItemRtLuggageLoaded", CAT_LUGGAGE, "important", unit_key=UNIT_SET),
    _i("trailer_hitch_check", "packingTemplateItemRtTrailerHitchCheck", CAT_LUGGAGE, unit_key=UNIT_SET),
    _i("trailer_lights_check", "packingTemplateItemRtTrailerLightsCheck", CAT_LUGGAGE, unit_key=UNIT_SET),
    _i("bike_rack_secured", "packingTemplateItemCamperBikeRack", CAT_LUGGAGE, unit_key=UNIT_SET),
    _i("fuel_tank_full", "packingTemplateItemRtFuelTankFull", CAT_FINAL, "critical", unit_key=UNIT_SET),
    _i("tyres_recheck", "packingTemplateItemRtTyresRecheck", CAT_FINAL, "critical", unit_key=UNIT_SET),
    _i("documents_in_car", "packingTemplateItemRtDocumentsInCar", CAT_FINAL, "critical", unit_key=UNIT_SET),
    _i("navigation_set", "packingTemplateItemRtNavigationSet", CAT_FINAL, "important", unit_key=UNIT_SET),
    _i("emergency_kit_accessible", "packingTemplateItemRtEmergencyKitAccessible", CAT_FINAL, "important", unit_key=UNIT_SET),
    _i("mirrors_adjusted", "packingTemplateItemRtMirrorsAdjusted", CAT_FINAL, "important", unit_key=UNIT_SET),
]

DOCUMENTS_SPECS: list[ItemSpec] = [
    _i("identity", "packingTemplateItemIdentityDocument", CAT_DOCS, "critical"),
    _i("passport", "packingTemplateItemPassport", CAT_DOCS, "critical"),
    _i("wallet", "packingTemplateItemWallet", CAT_DOCS, "important"),
    _i("travel_insurance", "packingTemplateItemRtTravelInsurance", CAT_DOCS, "important"),
    _i("emergency_contacts", "packingTemplateItemRtEmergencyContacts", CAT_DOCS, "important", unit_key=UNIT_SET),
    _i("booking_confirmations", "packingTemplateItemRtBookingConfirmations", CAT_DOCS, unit_key=UNIT_SET),
    _i("copies", "packingTemplateItemDocCopies", CAT_DOCS, unit_key=UNIT_SET),
    _i("visa", "packingTemplateItemDocVisa", CAT_DOCS, "important"),
    _i("idp", "packingTemplateItemDocInternationalDrivingPermit", CAT_DOCS),
    _i("bank_cards", "packingTemplateItemDocBankCards", CAT_DOCS, "important", unit_key=UNIT_SET),
    _i("cash", "packingTemplateItemDocCash", CAT_DOCS, "important"),
    _i("payment_ready", "packingTemplateItemRtPaymentReady", CAT_DOCS, "important", unit_key=UNIT_SET),
    _i("printed_contacts", "packingTemplateItemDocEmergencyContactsPrinted", CAT_DOCS, unit_key=UNIT_SET),
    _i("travel_permits", "packingTemplateItemDocTravelPermits", CAT_DOCS, unit_key=UNIT_SET),
    _i("medical_insurance", "packingTemplateItemDocMedicalInsurance", CAT_DOCS, "important"),
    _i("hotel_reservations", "packingTemplateItemDocHotelReservations", CAT_DOCS, unit_key=UNIT_SET),
    _i("rental_agreements", "packingTemplateItemDocRentalAgreements", CAT_DOCS, unit_key=UNIT_SET),
    _i("power_of_attorney", "packingTemplateItemDocPowerOfAttorney", CAT_DOCS),
    _i("european_health_card", "packingTemplateItemDocEuropeanHealthCard", CAT_DOCS, "important"),
    _i("emergency_cash", "packingTemplateItemDocEmergencyCash", CAT_DOCS),
    _i("student_id", "packingTemplateItemDocStudentId", CAT_DOCS),
]

CLOTHING_SPECS: list[ItemSpec] = [
    _i("weather", "packingTemplateItemWeatherAppropriateClothing", CAT_CLOTH, "important", unit_key=UNIT_SET),
    _i("warm_layers", "packingTemplateItemWarmLayers", CAT_CLOTH, "important", unit_key=UNIT_SET),
    _i("rain_jacket", "packingTemplateItemRainJacket", CAT_CLOTH, "important"),
    _i("comfortable_shoes", "packingTemplateItemRtComfortableShoes", CAT_CLOTH, "important", unit_key=UNIT_PAIR),
    _i("change_of_clothes", "packingTemplateItemRtChangeOfClothes", CAT_CLOTH, unit_key=UNIT_SET),
    _i("hat_cap", "packingTemplateItemRtHatCap", CAT_CLOTH),
    _i("swimwear", "packingTemplateItemSwimwear", CAT_CLOTH, unit_key=UNIT_SET),
    _i("sandals", "packingTemplateItemSandals", CAT_CLOTH, unit_key=UNIT_PAIR),
    _i("hiking_boots", "packingTemplateItemHikingBoots", CAT_CLOTH, unit_key=UNIT_PAIR),
    _i("sunglasses", "packingTemplateItemSunglasses", CAT_CLOTH, unit_key=UNIT_PAIR),
    _i("underwear", "packingTemplateItemClothUnderwear", CAT_CLOTH, unit_key=UNIT_SET),
    _i("socks", "packingTemplateItemClothSocks", CAT_CLOTH, unit_key=UNIT_SET),
    _i("pajamas", "packingTemplateItemClothPajamas", CAT_CLOTH, unit_key=UNIT_SET),
    _i("tshirts", "packingTemplateItemClothTshirts", CAT_CLOTH, unit_key=UNIT_SET),
    _i("trousers", "packingTemplateItemClothTrousers", CAT_CLOTH, unit_key=UNIT_SET),
    _i("shorts", "packingTemplateItemClothShorts", CAT_CLOTH, unit_key=UNIT_SET),
    _i("dress", "packingTemplateItemClothDress", CAT_CLOTH),
    _i("belt", "packingTemplateItemClothBelt", CAT_CLOTH),
    _i("scarf", "packingTemplateItemClothScarf", CAT_CLOTH),
    _i("gloves", "packingTemplateItemClothGloves", CAT_CLOTH, unit_key=UNIT_PAIR),
    _i("thermal_underwear", "packingTemplateItemClothThermalUnderwear", CAT_CLOTH, unit_key=UNIT_SET),
    _i("fleece", "packingTemplateItemClothFleece", CAT_CLOTH),
    _i("windbreaker", "packingTemplateItemClothWindbreaker", CAT_CLOTH),
    _i("formal_outfit", "packingTemplateItemFormalAttire", CAT_CLOTH, unit_key=UNIT_SET),
    _i("sleepwear", "packingTemplateItemClothSleepwear", CAT_CLOTH, unit_key=UNIT_SET),
    _i("sportswear", "packingTemplateItemClothSportswear", CAT_CLOTH, unit_key=UNIT_SET),
    _i("swim_cover", "packingTemplateItemClothSwimCover", CAT_CLOTH),
    _i("flip_flops", "packingTemplateItemClothFlipFlops", CAT_CLOTH, unit_key=UNIT_PAIR),
    _i("walking_shoes", "packingTemplateItemClothWalkingShoes", CAT_CLOTH, unit_key=UNIT_PAIR),
    _i("winter_coat", "packingTemplateItemClothWinterCoat", CAT_CLOTH),
    _i("light_jacket", "packingTemplateItemClothLightJacket", CAT_CLOTH),
    _i("leggings", "packingTemplateItemClothLeggings", CAT_CLOTH, unit_key=UNIT_PAIR),
    _i("skirt", "packingTemplateItemClothSkirt", CAT_CLOTH),
    _i("blouse", "packingTemplateItemClothBlouse", CAT_CLOTH),
    _i("cardigan", "packingTemplateItemClothCardigan", CAT_CLOTH),
    _i("beanie", "packingTemplateItemClothBeanie", CAT_CLOTH),
    _i("sun_hat", "packingTemplateItemClothSunHat", CAT_CLOTH),
    _i("packing_cubes", "packingTemplateItemClothPackingCubes", CAT_CLOTH, unit_key=UNIT_SET),
    _i("laundry_bag", "packingTemplateItemClothLaundryBag", CAT_CLOTH),
    _i("travel_umbrella", "packingTemplateItemClothTravelUmbrella", CAT_CLOTH),
]

TOILETRIES_SPECS: list[ItemSpec] = [
    _i("toothbrush", "packingTemplateItemToothbrush", CAT_TOILET),
    _i("toothpaste", "packingTemplateItemRtToothpaste", CAT_TOILET, unit_key=UNIT_PACK),
    _i("deodorant", "packingTemplateItemRtDeodorant", CAT_TOILET),
    _i("tissues", "packingTemplateItemRtTissues", CAT_TOILET, unit_key=UNIT_PACK),
    _i("lip_balm", "packingTemplateItemRtLipBalm", CAT_TOILET),
    _i("hand_soap", "packingTemplateItemRtHandSoap", CAT_TOILET, unit_key=UNIT_PACK),
    _i("shower_gel", "packingTemplateItemRtShowerGel", CAT_TOILET, unit_key=UNIT_PACK),
    _i("shampoo", "packingTemplateItemHygieneShampoo", CAT_TOILET, unit_key=UNIT_PACK),
    _i("conditioner", "packingTemplateItemHygieneConditioner", CAT_TOILET, unit_key=UNIT_PACK),
    _i("razor", "packingTemplateItemHygieneRazor", CAT_TOILET),
    _i("shaving_cream", "packingTemplateItemHygieneShavingCream", CAT_TOILET, unit_key=UNIT_PACK),
    _i("hairbrush", "packingTemplateItemHygieneHairbrush", CAT_TOILET),
    _i("hair_ties", "packingTemplateItemHygieneHairTies", CAT_TOILET, unit_key=UNIT_SET),
    _i("sunscreen", "packingTemplateItemSunscreen", CAT_TOILET, needs_purchase=True, unit_key=UNIT_PACK),
    _i("moisturizer", "packingTemplateItemHygieneMoisturizer", CAT_TOILET, unit_key=UNIT_PACK),
    _i("makeup_bag", "packingTemplateItemHygieneMakeupBag", CAT_TOILET),
    _i("contact_lens", "packingTemplateItemHygieneContactLens", CAT_TOILET, unit_key=UNIT_SET),
    _i("contact_solution", "packingTemplateItemHygieneContactSolution", CAT_TOILET, unit_key=UNIT_PACK),
    _i("glasses", "packingTemplateItemHygieneGlasses", CAT_TOILET, unit_key=UNIT_PAIR),
    _i("nail_clippers", "packingTemplateItemHygieneNailClippers", CAT_TOILET),
    _i("cotton_swabs", "packingTemplateItemHygieneCottonSwabs", CAT_TOILET, unit_key=UNIT_PACK),
    _i("wet_wipes", "packingTemplateItemHygieneWetWipes", CAT_TOILET, unit_key=UNIT_PACK),
    _i("hand_sanitizer", "packingTemplateItemRtHandSanitizer", CAT_TOILET, unit_key=UNIT_PACK),
    _i("dental_floss", "packingTemplateItemHygieneDentalFloss", CAT_TOILET),
    _i("mouthwash", "packingTemplateItemHygieneMouthwash", CAT_TOILET, unit_key=UNIT_PACK),
    _i("period_products", "packingTemplateItemHygienePeriodProducts", CAT_TOILET, unit_key=UNIT_PACK),
    _i("travel_towel", "packingTemplateItemHygieneTravelTowel", CAT_TOILET),
    _i("toiletry_bag", "packingTemplateItemHygieneToiletryBag", CAT_TOILET),
]

HEALTH_SPECS: list[ItemSpec] = [
    _i("medicines", "packingTemplateItemMedicines", CAT_HEALTH, "critical", unit_key=UNIT_PACK, note_key="packingTemplateNotePrescriptionMeds"),
    _i("first_aid", "packingTemplateItemFirstAidKit", CAT_HEALTH, "critical", unit_key=UNIT_SET),
    _i("motion_sickness", "packingTemplateItemRtMotionSickness", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("pain_relievers", "packingTemplateItemRtPainRelievers", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("allergy_meds", "packingTemplateItemRtAllergyMeds", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("hand_sanitizer", "packingTemplateItemRtHandSanitizer", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("insect_repellent", "packingTemplateItemRtInsectRepellent", CAT_HEALTH, needs_purchase=True, unit_key=UNIT_PACK),
    _i("bandages", "packingTemplateItemRtBandages", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("antiseptic_wipes", "packingTemplateItemRtAntisepticWipes", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("travel_sickness_bags", "packingTemplateItemRtTravelSicknessBags", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("eye_drops", "packingTemplateItemRtEyeDrops", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("thermometer", "packingTemplateItemHealthThermometer", CAT_HEALTH),
    _i("plasters", "packingTemplateItemHealthPlasters", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("antihistamine", "packingTemplateItemHealthAntihistamine", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("rehydration", "packingTemplateItemHealthRehydration", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("sunburn_gel", "packingTemplateItemHealthSunburnGel", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("blister_plasters", "packingTemplateItemHealthBlisterPlasters", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("prescription_list", "packingTemplateItemHealthPrescriptionList", CAT_HEALTH),
    _i("medical_certificate", "packingTemplateItemHealthMedicalCertificate", CAT_HEALTH),
    _i("vitamins", "packingTemplateItemHealthVitamins", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("hand_cream", "packingTemplateItemHealthHandCream", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("cough_drops", "packingTemplateItemHealthCoughDrops", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("stomach_remedy", "packingTemplateItemHealthStomachRemedy", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("tweezers", "packingTemplateItemHealthTweezers", CAT_HEALTH),
    _i("scissors", "packingTemplateItemHealthScissors", CAT_HEALTH),
    _i("face_masks", "packingTemplateItemHealthFaceMasks", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("covid_tests", "packingTemplateItemHealthCovidTests", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("epipen", "packingTemplateItemHealthEpipen", CAT_HEALTH, "important"),
    _i("inhaler", "packingTemplateItemHealthInhaler", CAT_HEALTH, "important"),
    _i("blood_pressure_monitor", "packingTemplateItemHealthBloodPressureMonitor", CAT_HEALTH),
    _i("glucose_tablets", "packingTemplateItemHealthGlucoseTablets", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("heating_pads", "packingTemplateItemHealthHeatingPads", CAT_HEALTH, unit_key=UNIT_PACK),
    _i("ice_pack", "packingTemplateItemHealthIcePack", CAT_HEALTH),
    _i("medical_id_bracelet", "packingTemplateItemHealthMedicalIdBracelet", CAT_HEALTH),
]

ELECTRONICS_SPECS: list[ItemSpec] = [
    _i("phone_charger", "packingTemplateItemPhoneCharger", CAT_ELEC, "critical"),
    _i("travel_adapter", "packingTemplateItemTravelAdapter", CAT_ELEC, "important", needs_purchase=True),
    _i("headphones", "packingTemplateItemHeadphones", CAT_ELEC),
    _i("portable_power_bank", "packingTemplateItemRtPortablePowerBank", CAT_ELEC, "important", needs_purchase=True),
    _i("charging_cables", "packingTemplateItemRtChargingCables", CAT_ELEC, unit_key=UNIT_SET),
    _i("laptop", "packingTemplateItemLaptop", CAT_ELEC, "important"),
    _i("laptop_charger", "packingTemplateItemElecLaptopCharger", CAT_ELEC, "important"),
    _i("tablet", "packingTemplateItemElecTablet", CAT_ELEC),
    _i("tablet_charger", "packingTemplateItemElecTabletCharger", CAT_ELEC),
    _i("camera", "packingTemplateItemElecCamera", CAT_ELEC),
    _i("camera_charger", "packingTemplateItemElecCameraCharger", CAT_ELEC),
    _i("memory_cards", "packingTemplateItemElecMemoryCards", CAT_ELEC, unit_key=UNIT_SET),
    _i("usb_drive", "packingTemplateItemElecUsbDrive", CAT_ELEC),
    _i("ebook_reader", "packingTemplateItemElecEbookReader", CAT_ELEC),
    _i("smartwatch_charger", "packingTemplateItemElecSmartwatchCharger", CAT_ELEC),
    _i("extension_cord", "packingTemplateItemElecExtensionCord", CAT_ELEC),
    _i("multi_usb_charger", "packingTemplateItemElecMultiUsbCharger", CAT_ELEC),
    _i("sim_card", "packingTemplateItemElecSimCard", CAT_ELEC),
    _i("portable_router", "packingTemplateItemElecPortableRouter", CAT_ELEC),
    _i("noise_cancelling", "packingTemplateItemElecNoiseCancelling", CAT_ELEC),
    _i("bluetooth_speaker", "packingTemplateItemElecBluetoothSpeaker", CAT_ELEC),
    _i("action_camera", "packingTemplateItemElecActionCamera", CAT_ELEC),
    _i("drone", "packingTemplateItemElecDrone", CAT_ELEC),
    _i("spare_batteries", "packingTemplateItemElecSpareBatteries", CAT_ELEC, unit_key=UNIT_SET),
    _i("battery_charger", "packingTemplateItemElecBatteryCharger", CAT_ELEC),
    _i("hdmi_cable", "packingTemplateItemElecHdmiCable", CAT_ELEC),
    _i("projector", "packingTemplateItemElecProjector", CAT_ELEC),
    _i("presentation_remote", "packingTemplateItemElecPresentationRemote", CAT_ELEC),
    _i("vpn_setup", "packingTemplateItemElecVpnSetup", CAT_ELEC, unit_key=UNIT_SET),
    _i("cloud_backup", "packingTemplateItemElecCloudBackup", CAT_ELEC, unit_key=UNIT_SET),
    _i("offline_entertainment", "packingTemplateItemElecOfflineEntertainment", CAT_ELEC, unit_key=UNIT_SET),
]

FOOD_SPECS: list[ItemSpec] = [
    _i("snacks", "packingTemplateItemSnacks", CAT_FOOD, unit_key=UNIT_PACK),
    _i("water_bottle", "packingTemplateItemWaterBottle", CAT_FOOD, "important"),
    _i("cool_bag", "packingTemplateItemRtCoolBag", CAT_FOOD, needs_purchase=True),
    _i("thermos_flask", "packingTemplateItemRtThermosFlask", CAT_FOOD),
    _i("non_perishable_food", "packingTemplateItemRtNonPerishableFood", CAT_FOOD, unit_key=UNIT_PACK),
    _i("travel_mugs", "packingTemplateItemRtTravelMugs", CAT_FOOD, unit_key=UNIT_PAIR),
    _i("reusable_cutlery", "packingTemplateItemRtReusableCutlery", CAT_FOOD, unit_key=UNIT_SET),
    _i("wet_wipes_food", "packingTemplateItemRtWetWipesFood", CAT_FOOD, unit_key=UNIT_PACK),
    _i("coffee_tea", "packingTemplateItemRtCoffeeTea", CAT_FOOD, unit_key=UNIT_PACK),
    _i("energy_bars", "packingTemplateItemFoodEnergyBars", CAT_FOOD, unit_key=UNIT_PACK),
    _i("fruit", "packingTemplateItemFoodFruit", CAT_FOOD, unit_key=UNIT_PACK),
    _i("nuts", "packingTemplateItemFoodNuts", CAT_FOOD, unit_key=UNIT_PACK),
    _i("sandwiches", "packingTemplateItemFoodSandwiches", CAT_FOOD, unit_key=UNIT_PACK),
    _i("instant_soup", "packingTemplateItemFoodInstantSoup", CAT_FOOD, unit_key=UNIT_PACK),
    _i("cereal", "packingTemplateItemFoodCereal", CAT_FOOD, unit_key=UNIT_PACK),
    _i("milk", "packingTemplateItemFoodMilk", CAT_FOOD, unit_key=UNIT_PACK),
    _i("juice", "packingTemplateItemFoodJuice", CAT_FOOD, unit_key=UNIT_PACK),
    _i("protein_shakes", "packingTemplateItemFoodProteinShakes", CAT_FOOD, unit_key=UNIT_PACK),
    _i("cooler_ice", "packingTemplateItemFoodCoolerIce", CAT_FOOD, unit_key=UNIT_PACK),
    _i("reusable_bottles", "packingTemplateItemFoodReusableBottles", CAT_FOOD, unit_key=UNIT_PAIR),
    _i("tea_bags", "packingTemplateItemFoodTeaBags", CAT_FOOD, unit_key=UNIT_PACK),
    _i("instant_coffee", "packingTemplateItemFoodInstantCoffee", CAT_FOOD, unit_key=UNIT_PACK),
    _i("spices", "packingTemplateItemFoodSpices", CAT_FOOD, unit_key=UNIT_SET),
]

HOME_PREP_SPECS: list[ItemSpec] = [
    _i("unplug_appliances", "packingTemplateItemRtUnplugAppliances", CAT_HOME, "important", unit_key=UNIT_SET),
    _i("set_heating_water", "packingTemplateItemRtSetHeatingWater", CAT_HOME, "important", unit_key=UNIT_SET),
    _i("secure_home", "packingTemplateItemRtSecureHome", CAT_HOME, "critical", unit_key=UNIT_SET),
    _i("pet_mail_care", "packingTemplateItemRtPetMailCare", CAT_HOME, "important", unit_key=UNIT_SET),
    _i("spare_house_key", "packingTemplateItemRtSpareHouseKey", CAT_HOME),
    _i("security_alarm", "packingTemplateItemRtSecurityAlarm", CAT_HOME, "important", unit_key=UNIT_SET),
    _i("take_out_trash", "packingTemplateItemRtTakeOutTrash", CAT_HOME, unit_key=UNIT_SET),
    _i("utility_shutoff", "packingTemplateItemRtUtilityShutoff", CAT_HOME, "important", unit_key=UNIT_SET),
    _i("notify_neighbor", "packingTemplateItemRtNotifyNeighbor", CAT_HOME, unit_key=UNIT_SET),
    _i("timer_lights", "packingTemplateItemRtTimerLights", CAT_HOME, unit_key=UNIT_SET),
    _i("fridge_cleared", "packingTemplateItemHomeFridgeCleared", CAT_HOME, unit_key=UNIT_SET),
    _i("plants_watered", "packingTemplateItemHomePlantsWatered", CAT_HOME, unit_key=UNIT_SET),
    _i("windows_closed", "packingTemplateItemHomeWindowsClosed", CAT_HOME, unit_key=UNIT_SET),
    _i("curtains_drawn", "packingTemplateItemHomeCurtainsDrawn", CAT_HOME, unit_key=UNIT_SET),
    _i("mail_hold", "packingTemplateItemHomeMailHold", CAT_HOME, unit_key=UNIT_SET),
    _i("cleaning_done", "packingTemplateItemHomeCleaningDone", CAT_HOME, unit_key=UNIT_SET),
    _i("laundry_done", "packingTemplateItemHomeLaundryDone", CAT_HOME, unit_key=UNIT_SET),
    _i("bills_paid", "packingTemplateItemHomeBillsPaid", CAT_HOME, unit_key=UNIT_SET),
    _i("appliances_off", "packingTemplateItemHomeAppliancesOff", CAT_HOME, unit_key=UNIT_SET),
    _i("smoke_detectors", "packingTemplateItemHomeSmokeDetectors", CAT_HOME, unit_key=UNIT_SET),
    _i("water_main", "packingTemplateItemHomeWaterMain", CAT_HOME, unit_key=UNIT_SET),
    _i("gas_shutoff", "packingTemplateItemHomeGasShutoff", CAT_HOME, unit_key=UNIT_SET),
    _i("garage_locked", "packingTemplateItemHomeGarageLocked", CAT_HOME, unit_key=UNIT_SET),
    _i("valuables_secured", "packingTemplateItemHomeValuablesSecured", CAT_HOME, unit_key=UNIT_SET),
    _i("emergency_contact_left", "packingTemplateItemHomeEmergencyContactLeft", CAT_HOME, unit_key=UNIT_SET),
]

FINAL_CHECKS_SPECS: list[ItemSpec] = [
    _i("phone_charged", "packingTemplateItemRtPhoneCharged", CAT_FINAL, "critical", unit_key=UNIT_SET),
    _i("departure_time_set", "packingTemplateItemRtDepartureTimeSet", CAT_FINAL, "important", unit_key=UNIT_SET),
    _i("passport_checked", "packingTemplateItemFinalPassportChecked", CAT_FINAL, "critical", unit_key=UNIT_SET),
    _i("tickets_checked", "packingTemplateItemFinalTicketsChecked", CAT_FINAL, "critical", unit_key=UNIT_SET),
    _i("wallet_checked", "packingTemplateItemFinalWalletChecked", CAT_FINAL, "important", unit_key=UNIT_SET),
    _i("keys_collected", "packingTemplateItemFinalKeysCollected", CAT_FINAL, "critical", unit_key=UNIT_SET),
    _i("bags_weighed", "packingTemplateItemFinalBagsWeighed", CAT_FINAL, unit_key=UNIT_SET),
    _i("weather_checked", "packingTemplateItemFinalWeatherChecked", CAT_FINAL, "important", unit_key=UNIT_SET),
    _i("transport_confirmed", "packingTemplateItemFinalTransportConfirmed", CAT_FINAL, "important", unit_key=UNIT_SET),
    _i("accommodation_confirmed", "packingTemplateItemFinalAccommodationConfirmed", CAT_FINAL, "important", unit_key=UNIT_SET),
    _i("chargers_packed", "packingTemplateItemFinalChargersPacked", CAT_FINAL, "important", unit_key=UNIT_SET),
    _i("medicines_packed", "packingTemplateItemFinalMedicinesPacked", CAT_FINAL, "critical", unit_key=UNIT_SET),
    _i("cash_withdrawn", "packingTemplateItemFinalCashWithdrawn", CAT_FINAL, unit_key=UNIT_SET),
    _i("out_of_office", "packingTemplateItemFinalOutOfOffice", CAT_FINAL, unit_key=UNIT_SET),
]

SUMMER_SPECS: list[ItemSpec] = [
    _i("sunscreen", "packingTemplateItemSunscreen", CAT_SUMMER, needs_purchase=True, unit_key=UNIT_PACK),
    _i("sun_shade", "packingTemplateItemRtSunShade", CAT_SUMMER, needs_purchase=True),
    _i("insect_repellent", "packingTemplateItemRtInsectRepellent", CAT_SUMMER, needs_purchase=True, unit_key=UNIT_PACK),
    _i("after_sun", "packingTemplateItemSummerAfterSun", CAT_SUMMER, unit_key=UNIT_PACK),
    _i("cooling_towel", "packingTemplateItemSummerCoolingTowel", CAT_SUMMER),
    _i("portable_fan", "packingTemplateItemSummerPortableFan", CAT_SUMMER),
    _i("hydration_tablets", "packingTemplateItemSummerHydrationTablets", CAT_SUMMER, unit_key=UNIT_PACK),
    _i("lip_balm_spf", "packingTemplateItemSummerLipBalmSpf", CAT_SUMMER),
    _i("aloe_vera", "packingTemplateItemSummerAloeVera", CAT_SUMMER, unit_key=UNIT_PACK),
    _i("snorkel", "packingTemplateItemSummerSnorkel", CAT_SUMMER, unit_key=UNIT_SET),
    _i("beach_umbrella", "packingTemplateItemSummerBeachUmbrella", CAT_SUMMER),
    _i("cooler", "packingTemplateItemSummerCooler", CAT_SUMMER),
]

WINTER_SPECS: list[ItemSpec] = [
    _i("snow_chains", "packingTemplateItemRtSnowChains", CAT_WINTER, needs_purchase=True, unit_key=UNIT_SET),
    _i("ice_scraper", "packingTemplateItemWinterIceScraper", CAT_WINTER),
    _i("deicer", "packingTemplateItemWinterDeicer", CAT_WINTER, unit_key=UNIT_PACK),
    _i("hand_warmers", "packingTemplateItemWinterHandWarmers", CAT_WINTER, unit_key=UNIT_PACK),
    _i("winter_boots", "packingTemplateItemWinterWinterBoots", CAT_WINTER, "important", unit_key=UNIT_PAIR),
    _i("ski_goggles", "packingTemplateItemWinterSkiGoggles", CAT_WINTER, unit_key=UNIT_PAIR),
    _i("ski_gloves", "packingTemplateItemWinterSkiGloves", CAT_WINTER, unit_key=UNIT_PAIR),
    _i("neck_warmer", "packingTemplateItemWinterNeckWarmer", CAT_WINTER),
    _i("antifreeze", "packingTemplateItemWinterAntifreeze", CAT_WINTER, unit_key=UNIT_PACK),
    _i("windshield_cover", "packingTemplateItemWinterWindshieldCover", CAT_WINTER),
    _i("snow_brush", "packingTemplateItemWinterSnowBrush", CAT_WINTER),
    _i("hot_drinks", "packingTemplateItemWinterHotDrinks", CAT_WINTER, unit_key=UNIT_PACK),
    _i("ski_pants", "packingTemplateItemWinterSkiPants", CAT_WINTER),
    _i("base_layers", "packingTemplateItemWinterBaseLayers", CAT_WINTER, unit_key=UNIT_SET),
    _i("ear_muffs", "packingTemplateItemWinterEarMuffs", CAT_WINTER, unit_key=UNIT_PAIR),
    _i("traction_aids", "packingTemplateItemWinterTractionAids", CAT_WINTER, unit_key=UNIT_SET),
]

MOTORCYCLE_SPECS: list[ItemSpec] = [
    _i("helmet", "packingTemplateItemMotoHelmet", CAT_MOTO, "critical"),
    _i("gloves", "packingTemplateItemMotoGloves", CAT_MOTO, "critical", unit_key=UNIT_PAIR),
    _i("jacket", "packingTemplateItemMotoJacket", CAT_MOTO, "critical"),
    _i("trousers", "packingTemplateItemMotoTrousers", CAT_MOTO, "important"),
    _i("boots", "packingTemplateItemMotoBoots", CAT_MOTO, "critical", unit_key=UNIT_PAIR),
    _i("rain_suit", "packingTemplateItemMotoRainSuit", CAT_MOTO, "important", unit_key=UNIT_SET),
    _i("intercom", "packingTemplateItemMotoIntercom", CAT_MOTO, "important"),
    _i("toolkit", "packingTemplateItemMotoToolkit", CAT_MOTO, "important", unit_key=UNIT_SET),
    _i("chain_lube", "packingTemplateItemMotoChainLube", CAT_MOTO, unit_key=UNIT_PACK),
    _i("tire_repair", "packingTemplateItemMotoTireRepair", CAT_MOTO, unit_key=UNIT_SET),
    _i("documents", "packingTemplateItemMotoDocuments", CAT_MOTO, "critical", unit_key=UNIT_SET),
    _i("phone_mount", "packingTemplateItemMotoPhoneMount", CAT_MOTO, "important"),
    _i("usb_charger", "packingTemplateItemMotoUsbCharger", CAT_MOTO, "important"),
    _i("spare_gloves", "packingTemplateItemMotoSpareGloves", CAT_MOTO, unit_key=UNIT_PAIR),
    _i("balaclava", "packingTemplateItemMotoBalaclava", CAT_MOTO),
    _i("ear_plugs", "packingTemplateItemMotoEarPlugs", CAT_MOTO, unit_key=UNIT_PAIR),
    _i("hydration_pack", "packingTemplateItemMotoHydrationPack", CAT_MOTO),
    _i("tank_bag", "packingTemplateItemMotoTankBag", CAT_MOTO),
    _i("saddlebags", "packingTemplateItemMotoSaddlebags", CAT_MOTO, unit_key=UNIT_SET),
    _i("bungee_cords", "packingTemplateItemMotoBungeeCords", CAT_MOTO, unit_key=UNIT_SET),
    _i("rain_covers", "packingTemplateItemMotoRainCovers", CAT_MOTO, unit_key=UNIT_SET),
    _i("disc_lock", "packingTemplateItemMotoDiscLock", CAT_MOTO, "important"),
    _i("chain_lock", "packingTemplateItemMotoChainLock", CAT_MOTO, "important"),
    _i("cover", "packingTemplateItemMotoCover", CAT_MOTO),
    _i("spare_key", "packingTemplateItemMotoSpareKey", CAT_MOTO),
    _i("visor_cleaner", "packingTemplateItemMotoVisorCleaner", CAT_MOTO, unit_key=UNIT_PACK),
    _i("spare_visor", "packingTemplateItemMotoSpareVisor", CAT_MOTO),
    _i("reflective_tape", "packingTemplateItemMotoReflectiveTape", CAT_MOTO, unit_key=UNIT_PACK),
    _i("emergency_contact", "packingTemplateItemMotoEmergencyContact", CAT_MOTO),
    _i("route_plan", "packingTemplateItemRtRoutePlan", CAT_MOTO, "important", unit_key=UNIT_SET),
    _i("offline_maps", "packingTemplateItemRtOfflineMaps", CAT_MOTO, "important", unit_key=UNIT_SET),
    _i("fuel_plan", "packingTemplateItemRtFuelPlan", CAT_MOTO, "important", unit_key=UNIT_SET),
    _i("protective_pads", "packingTemplateItemMotoProtectivePads", CAT_MOTO, unit_key=UNIT_SET),
    _i("neck_brace", "packingTemplateItemMotoNeckBrace", CAT_MOTO),
    _i("rain_gloves", "packingTemplateItemMotoRainGloves", CAT_MOTO, unit_key=UNIT_PAIR),
]

BICYCLE_SPECS: list[ItemSpec] = [
    _i("helmet", "packingTemplateItemBikeHelmet", CAT_BIKE, "critical"),
    _i("repair_kit", "packingTemplateItemBikeRepairKit", CAT_BIKE, "important", unit_key=UNIT_SET),
    _i("spare_tubes", "packingTemplateItemBikeSpareTubes", CAT_BIKE, "important", unit_key=UNIT_SET),
    _i("pump", "packingTemplateItemBikePump", CAT_BIKE, "important"),
    _i("multi_tool", "packingTemplateItemRtMultiTool", CAT_BIKE, "important"),
    _i("cage", "packingTemplateItemBikeBottleCage", CAT_BIKE),
    _i("lights_front", "packingTemplateItemBikeLightsFront", CAT_BIKE, "critical"),
    _i("lights_rear", "packingTemplateItemBikeLightsRear", CAT_BIKE, "critical"),
    _i("reflectors", "packingTemplateItemBikeReflectors", CAT_BIKE, unit_key=UNIT_SET),
    _i("high_vis_vest", "packingTemplateItemRtHighVisVest", CAT_BIKE, "important"),
    _i("lock", "packingTemplateItemBikeLock", CAT_BIKE, "important"),
    _i("cycling_gloves", "packingTemplateItemBikeCyclingGloves", CAT_BIKE, unit_key=UNIT_PAIR),
    _i("cycling_shorts", "packingTemplateItemBikeCyclingShorts", CAT_BIKE),
    _i("jersey", "packingTemplateItemBikeJersey", CAT_BIKE),
    _i("saddle_cover", "packingTemplateItemBikeSaddleCover", CAT_BIKE),
    _i("panniers", "packingTemplateItemBikePanniers", CAT_BIKE, unit_key=UNIT_SET),
    _i("bike_bag", "packingTemplateItemBikeBag", CAT_BIKE),
    _i("chain_lube", "packingTemplateItemBikeChainLube", CAT_BIKE, unit_key=UNIT_PACK),
    _i("tire_levers", "packingTemplateItemBikeTireLevers", CAT_BIKE, unit_key=UNIT_SET),
    _i("patch_kit", "packingTemplateItemBikePatchKit", CAT_BIKE, unit_key=UNIT_SET),
    _i("energy_gels", "packingTemplateItemBikeEnergyGels", CAT_BIKE, unit_key=UNIT_PACK),
    _i("route_plan", "packingTemplateItemRtRoutePlan", CAT_BIKE, "important", unit_key=UNIT_SET),
    _i("offline_maps", "packingTemplateItemRtOfflineMaps", CAT_BIKE, "important", unit_key=UNIT_SET),
    _i("spare_chain_link", "packingTemplateItemBikeSpareChainLink", CAT_BIKE),
    _i("cycling_shoes", "packingTemplateItemBikeCyclingShoes", CAT_BIKE, unit_key=UNIT_PAIR),
    _i("cleats", "packingTemplateItemBikeCleats", CAT_BIKE, unit_key=UNIT_PAIR),
    _i("arm_warmers", "packingTemplateItemBikeArmWarmers", CAT_BIKE, unit_key=UNIT_PAIR),
    _i("leg_warmers", "packingTemplateItemBikeLegWarmers", CAT_BIKE, unit_key=UNIT_PAIR),
    _i("bike_computer", "packingTemplateItemBikeComputer", CAT_BIKE),
    _i("phone_mount", "packingTemplateItemBikePhoneMount", CAT_BIKE),
    _i("bell", "packingTemplateItemBikeBell", CAT_BIKE),
]

CAMPER_SPECS: list[ItemSpec] = [
    _i("hookup_cable", "packingTemplateItemCamperHookupCable", CAT_CAMPER, "critical"),
    _i("adapter_plug", "packingTemplateItemCamperAdapterPlug", CAT_CAMPER, "important"),
    _i("gas_bottle", "packingTemplateItemCamperGasBottle", CAT_CAMPER, "critical"),
    _i("gas_regulator", "packingTemplateItemCamperGasRegulator", CAT_CAMPER, "important"),
    _i("leveling_blocks", "packingTemplateItemCamperLevelingBlocks", CAT_CAMPER, "important", unit_key=UNIT_SET),
    _i("wheel_chocks", "packingTemplateItemRtWheelChocks", CAT_CAMPER, unit_key=UNIT_PAIR),
    _i("fresh_water_hose", "packingTemplateItemCamperFreshWaterHose", CAT_CAMPER, "important"),
    _i("waste_hose", "packingTemplateItemCamperWasteHose", CAT_CAMPER, "important"),
    _i("hose_fittings", "packingTemplateItemCamperHoseFittings", CAT_CAMPER, unit_key=UNIT_SET),
    _i("chemical_toilet", "packingTemplateItemCamperChemicalToilet", CAT_CAMPER, unit_key=UNIT_PACK),
    _i("awning", "packingTemplateItemCamperAwning", CAT_CAMPER),
    _i("awning_pegs", "packingTemplateItemCamperAwningPegs", CAT_CAMPER, unit_key=UNIT_SET),
    _i("mallet", "packingTemplateItemCamperMallet", CAT_CAMPER),
    _i("ground_sheet", "packingTemplateItemCamperGroundSheet", CAT_CAMPER),
    _i("camping_chairs", "packingTemplateItemCamperCampingChairs", CAT_CAMPER, unit_key=UNIT_PAIR),
    _i("camping_table", "packingTemplateItemCamperCampingTable", CAT_CAMPER),
    _i("cookware", "packingTemplateItemCamperCookware", CAT_CAMPER, unit_key=UNIT_SET),
    _i("camping_stove", "packingTemplateItemCampingStove", CAT_CAMPER, "important"),
    _i("kitchen_utensils", "packingTemplateItemCamperKitchenUtensils", CAT_CAMPER, unit_key=UNIT_SET),
    _i("coolbox", "packingTemplateItemCamperCoolbox", CAT_CAMPER, "important"),
    _i("bedding", "packingTemplateItemCamperBedding", CAT_CAMPER, unit_key=UNIT_SET),
    _i("pillows", "packingTemplateItemCamperPillows", CAT_CAMPER, unit_key=UNIT_PAIR),
    _i("sleeping_bags", "packingTemplateItemSleepingBag", CAT_CAMPER, unit_key=UNIT_SET),
    _i("flashlight", "packingTemplateItemFlashlight", CAT_CAMPER, "important"),
    _i("fire_extinguisher", "packingTemplateItemRtFireExtinguisher", CAT_CAMPER, "important"),
    _i("co_detector", "packingTemplateItemCamperCoDetector", CAT_CAMPER, "critical"),
    _i("smoke_detector", "packingTemplateItemCamperSmokeDetector", CAT_CAMPER, "important"),
    _i("toolkit", "packingTemplateItemCamperToolkit", CAT_CAMPER, unit_key=UNIT_SET),
    _i("duct_tape", "packingTemplateItemRtDuctTape", CAT_CAMPER, unit_key=UNIT_PACK),
    _i("fuse_kit", "packingTemplateItemCamperFuseKit", CAT_CAMPER, unit_key=UNIT_SET),
    _i("spare_bulbs", "packingTemplateItemCamperSpareBulbs", CAT_CAMPER, unit_key=UNIT_SET),
    _i("water_filter", "packingTemplateItemCamperWaterFilter", CAT_CAMPER),
    _i("water_containers", "packingTemplateItemCamperWaterContainers", CAT_CAMPER, unit_key=UNIT_SET),
    _i("toilet_paper", "packingTemplateItemCamperToiletPaper", CAT_CAMPER, unit_key=UNIT_PACK),
    _i("cleaning_supplies", "packingTemplateItemCamperCleaningSupplies", CAT_CAMPER, unit_key=UNIT_SET),
    _i("insect_screen", "packingTemplateItemCamperInsectScreen", CAT_CAMPER),
    _i("curtain_ties", "packingTemplateItemCamperCurtainTies", CAT_CAMPER, unit_key=UNIT_SET),
    _i("tv_aerial", "packingTemplateItemCamperTvAerial", CAT_CAMPER),
    _i("satellite_dish", "packingTemplateItemCamperSatelliteDish", CAT_CAMPER),
    _i("bike_rack", "packingTemplateItemCamperBikeRack", CAT_CAMPER),
    _i("roof_ladder", "packingTemplateItemCamperRoofLadder", CAT_CAMPER),
    _i("awning_light", "packingTemplateItemCamperAwningLight", CAT_CAMPER),
    _i("outdoor_rug", "packingTemplateItemCamperOutdoorRug", CAT_CAMPER),
    _i("barbecue", "packingTemplateItemCamperBarbecue", CAT_CAMPER),
    _i("charcoal", "packingTemplateItemCamperCharcoal", CAT_CAMPER, unit_key=UNIT_PACK),
    _i("matches", "packingTemplateItemCamperMatches", CAT_CAMPER, unit_key=UNIT_PACK),
    _i("camping_cutlery", "packingTemplateItemCamperCampingCutlery", CAT_CAMPER, unit_key=UNIT_SET),
    _i("dish_washing", "packingTemplateItemCamperDishWashing", CAT_CAMPER, unit_key=UNIT_SET),
    _i("rubbish_bags", "packingTemplateItemRtTrashBags", CAT_CAMPER, unit_key=UNIT_PACK),
]

BABY_SPECS: list[ItemSpec] = [
    _i("diapers", "packingTemplateItemDiapers", CAT_BABY, "critical", unit_key=UNIT_PACK),
    _i("baby_food", "packingTemplateItemBabyFood", CAT_BABY, "critical", unit_key=UNIT_PACK),
    _i("formula", "packingTemplateItemBabyFormula", CAT_BABY, unit_key=UNIT_PACK),
    _i("bottles", "packingTemplateItemBabyBottles", CAT_BABY, unit_key=UNIT_SET),
    _i("bottle_brush", "packingTemplateItemBabyBottleBrush", CAT_BABY),
    _i("sterilizer", "packingTemplateItemBabySterilizer", CAT_BABY),
    _i("bibs", "packingTemplateItemBabyBibs", CAT_BABY, unit_key=UNIT_SET),
    _i("wipes", "packingTemplateItemBabyWipes", CAT_BABY, unit_key=UNIT_PACK),
    _i("rash_cream", "packingTemplateItemBabyRashCream", CAT_BABY, unit_key=UNIT_PACK),
    _i("changing_mat", "packingTemplateItemBabyChangingMat", CAT_BABY),
    _i("nappy_bags", "packingTemplateItemBabyNappyBags", CAT_BABY, unit_key=UNIT_PACK),
    _i("stroller", "packingTemplateItemBabyStroller", CAT_BABY, "important"),
    _i("car_seat", "packingTemplateItemBabyCarSeat", CAT_BABY, "critical"),
    _i("carrier", "packingTemplateItemBabyCarrier", CAT_BABY, "important"),
    _i("travel_cot", "packingTemplateItemBabyTravelCot", CAT_BABY, "important"),
    _i("sleeping_bag_baby", "packingTemplateItemBabySleepingBag", CAT_BABY),
    _i("blanket", "packingTemplateItemBabyBlanket", CAT_BABY),
    _i("favourite_toy", "packingTemplateItemFavoriteToy", CAT_BABY),
    _i("books", "packingTemplateItemBabyBooks", CAT_BABY, unit_key=UNIT_SET),
    _i("pacifier", "packingTemplateItemBabyPacifier", CAT_BABY, unit_key=UNIT_SET),
    _i("teether", "packingTemplateItemBabyTeether", CAT_BABY),
    _i("baby_clothes", "packingTemplateItemBabyClothes", CAT_BABY, unit_key=UNIT_SET),
    _i("baby_hat", "packingTemplateItemBabyHat", CAT_BABY),
    _i("baby_socks", "packingTemplateItemBabySocks", CAT_BABY, unit_key=UNIT_SET),
    _i("baby_shoes", "packingTemplateItemBabyShoes", CAT_BABY, unit_key=UNIT_PAIR),
    _i("sun_hat", "packingTemplateItemBabySunHat", CAT_BABY),
    _i("sunscreen_baby", "packingTemplateItemBabySunscreen", CAT_BABY, unit_key=UNIT_PACK),
    _i("baby_medicine", "packingTemplateItemBabyMedicine", CAT_BABY, unit_key=UNIT_PACK),
    _i("thermometer", "packingTemplateItemHealthThermometer", CAT_BABY, "important"),
    _i("nasal_aspirator", "packingTemplateItemBabyNasalAspirator", CAT_BABY),
    _i("baby_shampoo", "packingTemplateItemBabyShampoo", CAT_BABY, unit_key=UNIT_PACK),
    _i("baby_lotion", "packingTemplateItemBabyLotion", CAT_BABY, unit_key=UNIT_PACK),
    _i("baby_bath", "packingTemplateItemBabyBath", CAT_BABY),
    _i("towel_baby", "packingTemplateItemBabyTowel", CAT_BABY),
    _i("high_chair", "packingTemplateItemBabyHighChair", CAT_BABY),
    _i("booster_seat", "packingTemplateItemBabyBoosterSeat", CAT_BABY),
    _i("baby_monitor", "packingTemplateItemBabyMonitor", CAT_BABY),
    _i("night_light", "packingTemplateItemBabyNightLight", CAT_BABY),
    _i("white_noise", "packingTemplateItemBabyWhiteNoise", CAT_BABY),
    _i("snacks_baby", "packingTemplateItemBabySnacks", CAT_BABY, unit_key=UNIT_PACK),
    _i("sippy_cup", "packingTemplateItemBabySippyCup", CAT_BABY),
    _i("spill_mat", "packingTemplateItemBabySpillMat", CAT_BABY),
    _i("laundry_bags", "packingTemplateItemBabyLaundryBags", CAT_BABY, unit_key=UNIT_PACK),
    _i("portable_potty", "packingTemplateItemBabyPortablePotty", CAT_BABY),
    _i("potty_seat", "packingTemplateItemBabyPottySeat", CAT_BABY),
    _i("stroller_rain_cover", "packingTemplateItemBabyStrollerRainCover", CAT_BABY),
    _i("stroller_sunshade", "packingTemplateItemBabyStrollerSunshade", CAT_BABY),
    _i("baby_passport", "packingTemplateItemBabyPassport", CAT_BABY, "critical"),
    _i("health_records", "packingTemplateItemBabyHealthRecords", CAT_BABY, "important", unit_key=UNIT_SET),
    _i("travel_insurance_baby", "packingTemplateItemBabyTravelInsurance", CAT_BABY, "important"),
    _i("emergency_contacts", "packingTemplateItemBabyEmergencyContacts", CAT_BABY, unit_key=UNIT_SET),
    _i("child_medication_list", "packingTemplateItemBabyMedicationList", CAT_BABY),
    _i("breast_pump", "packingTemplateItemBabyBreastPump", CAT_BABY),
    _i("nursing_cover", "packingTemplateItemBabyNursingCover", CAT_BABY),
    _i("milk_storage", "packingTemplateItemBabyMilkStorage", CAT_BABY, unit_key=UNIT_SET),
    _i("cooler_bags", "packingTemplateItemBabyCoolerBags", CAT_BABY, unit_key=UNIT_SET),
    _i("baby_gate", "packingTemplateItemBabyGate", CAT_BABY),
    _i("outlet_covers", "packingTemplateItemBabyOutletCovers", CAT_BABY, unit_key=UNIT_SET),
    _i("cabinet_locks", "packingTemplateItemBabyCabinetLocks", CAT_BABY, unit_key=UNIT_SET),
    _i("first_aid_baby", "packingTemplateItemBabyFirstAid", CAT_BABY, unit_key=UNIT_SET),
]

CAT_SPECS: list[ItemSpec] = [
    _i("carrier", "packingTemplateItemPetCarrier", CAT_CAT, "critical"),
    _i("cat_food", "packingTemplateItemPetFood", CAT_CAT, "critical", unit_key=UNIT_PACK),
    _i("water_bowl", "packingTemplateItemPetWaterBowl", CAT_CAT, "important"),
    _i("food_bowls", "packingTemplateItemCatFoodBowls", CAT_CAT, unit_key=UNIT_SET),
    _i("litter_box", "packingTemplateItemCatLitterBox", CAT_CAT, "important"),
    _i("cat_litter", "packingTemplateItemCatLitter", CAT_CAT, unit_key=UNIT_PACK),
    _i("litter_scoop", "packingTemplateItemCatLitterScoop", CAT_CAT),
    _i("waste_bags", "packingTemplateItemCatWasteBags", CAT_CAT, unit_key=UNIT_PACK),
    _i("leash", "packingTemplateItemLeash", CAT_CAT),
    _i("harness", "packingTemplateItemCatHarness", CAT_CAT),
    _i("health_records", "packingTemplateItemPetHealthRecords", CAT_CAT, "critical", unit_key=UNIT_SET),
    _i("passport", "packingTemplateItemCatPassport", CAT_CAT, "critical"),
    _i("microchip", "packingTemplateItemCatMicrochip", CAT_CAT, "important"),
    _i("vaccination", "packingTemplateItemCatVaccination", CAT_CAT, "critical", unit_key=UNIT_SET),
    _i("medication", "packingTemplateItemCatMedication", CAT_CAT, unit_key=UNIT_PACK),
    _i("favourite_toy", "packingTemplateItemFavoriteToy", CAT_CAT),
    _i("scratching_pad", "packingTemplateItemCatScratchingPad", CAT_CAT),
    _i("bed", "packingTemplateItemCatBed", CAT_CAT),
    _i("blanket", "packingTemplateItemCatBlanket", CAT_CAT),
    _i("treats", "packingTemplateItemCatTreats", CAT_CAT, unit_key=UNIT_PACK),
    _i("grooming_brush", "packingTemplateItemCatGroomingBrush", CAT_CAT),
    _i("nail_clippers", "packingTemplateItemCatNailClippers", CAT_CAT),
    _i("wipes", "packingTemplateItemCatWipes", CAT_CAT, unit_key=UNIT_PACK),
    _i("calming_spray", "packingTemplateItemCatCalmingSpray", CAT_CAT, unit_key=UNIT_PACK),
    _i("pheromone", "packingTemplateItemCatPheromone", CAT_CAT),
    _i("travel_litter", "packingTemplateItemCatTravelLitter", CAT_CAT, unit_key=UNIT_PACK),
    _i("portable_fence", "packingTemplateItemCatPortableFence", CAT_CAT),
    _i("window_screen", "packingTemplateItemCatWindowScreen", CAT_CAT),
    _i("cooling_mat", "packingTemplateItemCatCoolingMat", CAT_CAT),
    _i("heating_pad", "packingTemplateItemCatHeatingPad", CAT_CAT),
    _i("water_fountain", "packingTemplateItemCatWaterFountain", CAT_CAT),
    _i("food_puzzle", "packingTemplateItemCatFoodPuzzle", CAT_CAT),
    _i("carrier_liner", "packingTemplateItemCatCarrierLiner", CAT_CAT),
    _i("seat_belt_clip", "packingTemplateItemCatSeatBeltClip", CAT_CAT),
    _i("id_tag", "packingTemplateItemCatIdTag", CAT_CAT),
    _i("recent_photo", "packingTemplateItemCatRecentPhoto", CAT_CAT),
    _i("vet_contact", "packingTemplateItemCatVetContact", CAT_CAT),
    _i("pet_insurance", "packingTemplateItemCatPetInsurance", CAT_CAT, "important"),
    _i("entry_permit", "packingTemplateItemCatEntryPermit", CAT_CAT, "important"),
    _i("tranquilizer", "packingTemplateItemCatTranquilizer", CAT_CAT, unit_key=UNIT_PACK),
]

BASIC_TRIP_SPECS: list[ItemSpec] = [
    _i("identity", "packingTemplateItemIdentityDocument", CAT_DOCS, "critical"),
    _i("wallet", "packingTemplateItemWallet", CAT_DOCS, "important"),
    _i("charger", "packingTemplateItemPhoneCharger", CAT_ELEC, "critical"),
    _i("medicines", "packingTemplateItemMedicines", CAT_HEALTH, "critical", unit_key=UNIT_PACK, note_key="packingTemplateNotePrescriptionMeds"),
    _i("clothing", "packingTemplateItemWeatherAppropriateClothing", CAT_CLOTH, "important", unit_key=UNIT_SET),
    _i("toothbrush", "packingTemplateItemToothbrush", CAT_TOILET),
]

AIR_TRAVEL_SPECS: list[ItemSpec] = [
    _i("passport", "packingTemplateItemPassport", CAT_DOCS, "critical"),
    _i("boarding_pass", "packingTemplateItemBoardingPass", CAT_DOCS, "critical"),
    _i("identity", "packingTemplateItemIdentityDocument", CAT_DOCS, "critical"),
    _i("visa", "packingTemplateItemDocVisa", CAT_DOCS, "important"),
    _i("booking_confirmations", "packingTemplateItemRtBookingConfirmations", CAT_DOCS, unit_key=UNIT_SET),
    _i("travel_insurance", "packingTemplateItemRtTravelInsurance", CAT_DOCS, "important"),
    _i("online_check_in", "packingTemplateItemFinalTicketsChecked", CAT_TRAVEL, "important", unit_key=UNIT_SET),
    _i("bags_weighed", "packingTemplateItemFinalBagsWeighed", CAT_TRAVEL, unit_key=UNIT_SET),
    _i("passport_checked", "packingTemplateItemFinalPassportChecked", CAT_TRAVEL, "critical", unit_key=UNIT_SET),
    _i("transport_confirmed", "packingTemplateItemFinalTransportConfirmed", CAT_TRAVEL, "important", unit_key=UNIT_SET),
    _i("noise_cancelling", "packingTemplateItemElecNoiseCancelling", CAT_TRAVEL),
    _i("motion_sickness", "packingTemplateItemRtMotionSickness", CAT_TRAVEL, unit_key=UNIT_PACK),
    _i("sickness_bags", "packingTemplateItemRtTravelSicknessBags", CAT_TRAVEL, unit_key=UNIT_PACK),
    _i("offline_entertainment", "packingTemplateItemElecOfflineEntertainment", CAT_TRAVEL, unit_key=UNIT_SET),
]

TRAIN_BUS_SPECS: list[ItemSpec] = [
    _i("ticket", "packingTemplateItemTicket", CAT_DOCS, "critical"),
    _i("identity", "packingTemplateItemIdentityDocument", CAT_DOCS, "critical"),
    _i("booking_confirmations", "packingTemplateItemRtBookingConfirmations", CAT_DOCS, unit_key=UNIT_SET),
    _i("tickets_checked", "packingTemplateItemFinalTicketsChecked", CAT_TRAVEL, "important", unit_key=UNIT_SET),
    _i("transport_confirmed", "packingTemplateItemFinalTransportConfirmed", CAT_TRAVEL, "important", unit_key=UNIT_SET),
    _i("offline_maps", "packingTemplateItemRtOfflineMaps", CAT_TRAVEL, unit_key=UNIT_SET),
    _i("rest_stops", "packingTemplateItemRtRestStops", CAT_TRAVEL, unit_key=UNIT_SET),
    _i("motion_sickness", "packingTemplateItemRtMotionSickness", CAT_TRAVEL, unit_key=UNIT_PACK),
    _i("headphones", "packingTemplateItemHeadphones", CAT_TRAVEL),
    _i("offline_entertainment", "packingTemplateItemElecOfflineEntertainment", CAT_TRAVEL, unit_key=UNIT_SET),
]

BEACH_SPECS: list[ItemSpec] = [
    _i("sunscreen", "packingTemplateItemSunscreen", CAT_BEACH, needs_purchase=True, unit_key=UNIT_PACK),
    _i("swimwear", "packingTemplateItemSwimwear", CAT_BEACH, unit_key=UNIT_SET),
    _i("towel", "packingTemplateItemTowel", CAT_BEACH),
    _i("sunglasses", "packingTemplateItemSunglasses", CAT_BEACH, unit_key=UNIT_PAIR),
    _i("sandals", "packingTemplateItemSandals", CAT_BEACH, unit_key=UNIT_PAIR),
    _i("beach_umbrella", "packingTemplateItemSummerBeachUmbrella", CAT_BEACH),
    _i("beach_bag", "packingTemplateItemSummerBeachBag", CAT_BEACH),
    _i("water_shoes", "packingTemplateItemSummerWaterShoes", CAT_BEACH, unit_key=UNIT_PAIR),
]

MOUNTAINS_SPECS: list[ItemSpec] = [
    _i("hiking_boots", "packingTemplateItemHikingBoots", CAT_OUTDOOR, unit_key=UNIT_PAIR),
    _i("warm_layers", "packingTemplateItemWarmLayers", CAT_OUTDOOR, unit_key=UNIT_SET),
    _i("rain_jacket", "packingTemplateItemRainJacket", CAT_OUTDOOR, "important"),
]

CAMPING_SPECS: list[ItemSpec] = [
    _i("tent", "packingTemplateItemTent", CAT_OUTDOOR),
    _i("sleeping_bag", "packingTemplateItemSleepingBag", CAT_OUTDOOR),
    _i("camping_stove", "packingTemplateItemCampingStove", CAT_OUTDOOR),
    _i("flashlight", "packingTemplateItemFlashlight", CAT_OUTDOOR, "important"),
]

BUSINESS_SPECS: list[ItemSpec] = [
    _i("business_cards", "packingTemplateItemBusinessCards", CAT_BUSINESS, unit_key=UNIT_SET),
    _i("notebook", "packingTemplateItemNotebook", CAT_BUSINESS),
    _i("formal_attire", "packingTemplateItemFormalAttire", CAT_BUSINESS, unit_key=UNIT_SET),
    _i("presentation_remote", "packingTemplateItemElecPresentationRemote", CAT_BUSINESS),
]

CHILD_SPECS: list[ItemSpec] = [
    _i("favorite_toy", "packingTemplateItemFavoriteToy", CAT_CHILD),
    _i("books", "packingTemplateItemBabyBooks", CAT_CHILD, unit_key=UNIT_SET),
    _i("snacks", "packingTemplateItemBabySnacks", CAT_CHILD, unit_key=UNIT_PACK),
    _i("sippy_cup", "packingTemplateItemBabySippyCup", CAT_CHILD),
    _i("booster_seat", "packingTemplateItemBabyBoosterSeat", CAT_CHILD),
    _i("sun_hat", "packingTemplateItemBabySunHat", CAT_CHILD),
]

PET_SPECS: list[ItemSpec] = [
    _i("carrier", "packingTemplateItemPetCarrier", CAT_PET, "critical"),
    _i("food", "packingTemplateItemPetFood", CAT_PET, "critical", unit_key=UNIT_PACK),
    _i("leash", "packingTemplateItemLeash", CAT_PET, "important"),
    _i("water_bowl", "packingTemplateItemPetWaterBowl", CAT_PET),
    _i("health_records", "packingTemplateItemPetHealthRecords", CAT_PET, "critical", unit_key=UNIT_SET),
    _i("treats", "packingTemplateItemFoodPetTreats", CAT_PET, unit_key=UNIT_PACK),
]

NEW_MODULAR_TEMPLATES: list[dict[str, Any]] = [
    {
        "id": "sys_tpl_documents",
        "nameKey": "packingTemplateDocuments",
        "descriptionKey": "packingTemplateDocumentsDesc",
        "iconKey": "description",
        "groupKey": GROUP_ESSENTIALS,
        "specs": DOCUMENTS_SPECS,
        "prefix": "doc",
    },
    {
        "id": "sys_tpl_clothing",
        "nameKey": "packingTemplateClothing",
        "descriptionKey": "packingTemplateClothingDesc",
        "iconKey": "checkroom",
        "groupKey": GROUP_ESSENTIALS,
        "specs": CLOTHING_SPECS,
        "prefix": "cloth",
    },
    {
        "id": "sys_tpl_toiletries",
        "nameKey": "packingTemplateToiletries",
        "descriptionKey": "packingTemplateToiletriesDesc",
        "iconKey": "soap",
        "groupKey": GROUP_ESSENTIALS,
        "specs": TOILETRIES_SPECS,
        "prefix": "toilet",
    },
    {
        "id": "sys_tpl_health",
        "nameKey": "packingTemplateHealth",
        "descriptionKey": "packingTemplateHealthDesc",
        "iconKey": "medical_services",
        "groupKey": GROUP_ESSENTIALS,
        "specs": HEALTH_SPECS,
        "prefix": "health",
    },
    {
        "id": "sys_tpl_electronics",
        "nameKey": "packingTemplateElectronics",
        "descriptionKey": "packingTemplateElectronicsDesc",
        "iconKey": "devices",
        "groupKey": GROUP_ESSENTIALS,
        "specs": ELECTRONICS_SPECS,
        "prefix": "elec",
    },
    {
        "id": "sys_tpl_food_drinks",
        "nameKey": "packingTemplateFoodDrinks",
        "descriptionKey": "packingTemplateFoodDrinksDesc",
        "iconKey": "restaurant",
        "groupKey": GROUP_ESSENTIALS,
        "specs": FOOD_SPECS,
        "prefix": "food",
    },
    {
        "id": "sys_tpl_home_prep",
        "nameKey": "packingTemplateHomePrep",
        "descriptionKey": "packingTemplateHomePrepDesc",
        "iconKey": "home",
        "groupKey": GROUP_BEFORE_LEAVING,
        "specs": HOME_PREP_SPECS,
        "prefix": "home",
    },
    {
        "id": "sys_tpl_final_checks",
        "nameKey": "packingTemplateFinalChecks",
        "descriptionKey": "packingTemplateFinalChecksDesc",
        "iconKey": "fact_check",
        "groupKey": GROUP_BEFORE_LEAVING,
        "specs": FINAL_CHECKS_SPECS,
        "prefix": "final",
    },
]

LEGACY_TEMPLATES: list[dict[str, Any]] = [
    {
        "id": "sys_tpl_basic_trip",
        "nameKey": "packingTemplateBasicTrip",
        "descriptionKey": "packingTemplateBasicTripDesc",
        "iconKey": "luggage",
        "groupKey": GROUP_ESSENTIALS,
        "specs": BASIC_TRIP_SPECS,
        "prefix": "basic",
    },
    {
        "id": "sys_tpl_air_travel",
        "nameKey": "packingTemplateAirTravel",
        "descriptionKey": "packingTemplateAirTravelDesc",
        "iconKey": "flight",
        "groupKey": GROUP_TRANSPORT,
        "specs": AIR_TRAVEL_SPECS,
        "prefix": "air",
    },
    {
        "id": "sys_tpl_train_bus",
        "nameKey": "packingTemplateTrainBusTravel",
        "descriptionKey": "packingTemplateTrainBusTravelDesc",
        "iconKey": "directions_transit",
        "groupKey": GROUP_TRANSPORT,
        "specs": TRAIN_BUS_SPECS,
        "prefix": "train",
    },
    {
        "id": "sys_tpl_beach",
        "nameKey": "packingTemplateBeach",
        "descriptionKey": "packingTemplateBeachDesc",
        "iconKey": "beach_access",
        "groupKey": GROUP_TRIP_TYPE,
        "specs": BEACH_SPECS,
        "prefix": "beach",
    },
    {
        "id": "sys_tpl_mountains",
        "nameKey": "packingTemplateMountains",
        "descriptionKey": "packingTemplateMountainsDesc",
        "iconKey": "terrain",
        "groupKey": GROUP_TRIP_TYPE,
        "specs": MOUNTAINS_SPECS,
        "prefix": "mountain",
    },
    {
        "id": "sys_tpl_camping",
        "nameKey": "packingTemplateCamping",
        "descriptionKey": "packingTemplateCampingDesc",
        "iconKey": "camping",
        "groupKey": GROUP_TRIP_TYPE,
        "specs": CAMPING_SPECS,
        "prefix": "camp",
    },
    {
        "id": "sys_tpl_business",
        "nameKey": "packingTemplateBusinessTrip",
        "descriptionKey": "packingTemplateBusinessTripDesc",
        "iconKey": "work",
        "groupKey": GROUP_TRIP_TYPE,
        "specs": BUSINESS_SPECS,
        "prefix": "business",
    },
    {
        "id": "sys_tpl_with_child",
        "nameKey": "packingTemplateTravellingWithChild",
        "descriptionKey": "packingTemplateTravellingWithChildDesc",
        "iconKey": "child_care",
        "groupKey": GROUP_TRAVELLERS,
        "specs": CHILD_SPECS,
        "prefix": "child",
    },
    {
        "id": "sys_tpl_with_pet",
        "nameKey": "packingTemplateTravellingWithPet",
        "descriptionKey": "packingTemplateTravellingWithPetDesc",
        "iconKey": "pets",
        "groupKey": GROUP_TRAVELLERS,
        "specs": PET_SPECS,
        "prefix": "pet",
    },
]

TRANSPORT_TEMPLATES: list[dict[str, Any]] = [
    {
        "id": "sys_tpl_motorcycle",
        "nameKey": "packingTemplateMotorcycle",
        "descriptionKey": "packingTemplateMotorcycleDesc",
        "iconKey": "two_wheeler",
        "groupKey": GROUP_TRANSPORT,
        "specs": MOTORCYCLE_SPECS,
        "prefix": "moto",
    },
    {
        "id": "sys_tpl_bicycle",
        "nameKey": "packingTemplateBicycle",
        "descriptionKey": "packingTemplateBicycleDesc",
        "iconKey": "pedal_bike",
        "groupKey": GROUP_TRANSPORT,
        "specs": BICYCLE_SPECS,
        "prefix": "bike",
    },
    {
        "id": "sys_tpl_camper",
        "nameKey": "packingTemplateCamper",
        "descriptionKey": "packingTemplateCamperDesc",
        "iconKey": "rv_hookup",
        "groupKey": GROUP_TRANSPORT,
        "specs": CAMPER_SPECS,
        "prefix": "camper",
    },
]

TRIP_TYPE_TEMPLATES: list[dict[str, Any]] = [
    {
        "id": "sys_tpl_summer",
        "nameKey": "packingTemplateSummer",
        "descriptionKey": "packingTemplateSummerDesc",
        "iconKey": "wb_sunny",
        "groupKey": GROUP_TRIP_TYPE,
        "specs": SUMMER_SPECS,
        "prefix": "summer",
    },
    {
        "id": "sys_tpl_winter",
        "nameKey": "packingTemplateWinter",
        "descriptionKey": "packingTemplateWinterDesc",
        "iconKey": "ac_unit",
        "groupKey": GROUP_TRIP_TYPE,
        "specs": WINTER_SPECS,
        "prefix": "winter",
    },
]

TRAVELLER_TEMPLATES: list[dict[str, Any]] = [
    {
        "id": "sys_tpl_with_baby",
        "nameKey": "packingTemplateWithBaby",
        "descriptionKey": "packingTemplateWithBabyDesc",
        "iconKey": "child_care",
        "groupKey": GROUP_TRAVELLERS,
        "specs": BABY_SPECS,
        "prefix": "baby",
    },
    {
        "id": "sys_tpl_with_cat",
        "nameKey": "packingTemplateWithCat",
        "descriptionKey": "packingTemplateWithCatDesc",
        "iconKey": "pets",
        "groupKey": GROUP_TRAVELLERS,
        "specs": CAT_SPECS,
        "prefix": "cat",
    },
]

# Backward-compatible alias used by the generator script.
NEW_TRANSPORT_TEMPLATES: list[dict[str, Any]] = (
    TRANSPORT_TEMPLATES + TRIP_TYPE_TEMPLATES + TRAVELLER_TEMPLATES
)


def build_items(specs: list[ItemSpec], id_prefix: str) -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []
    for sort_order, spec in enumerate(specs):
        suffix, name_key, category_key, priority, needs_purchase, unit_key, note_key = spec
        item: dict[str, Any] = {
            "id": f"{id_prefix}_{suffix}",
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


def build_template(meta: dict[str, Any]) -> dict[str, Any]:
    template = {
        "id": meta["id"],
        "nameKey": meta["nameKey"],
        "descriptionKey": meta["descriptionKey"],
        "iconKey": meta["iconKey"],
        "isSystem": True,
        "items": build_items(meta["specs"], meta["prefix"]),
    }
    if group_key := meta.get("groupKey"):
        template["groupKey"] = group_key
    return template


def build_car_travel_template() -> dict[str, Any]:
    return {
        "id": "sys_tpl_car_travel",
        "nameKey": "packingTemplateCarTravel",
        "descriptionKey": "packingTemplateCarTravelDesc",
        "iconKey": "directions_car",
        "groupKey": GROUP_TRANSPORT,
        "isSystem": True,
        "items": build_items(ROAD_TRIP_SPECS, "rt"),
    }


def build_all_system_templates() -> list[dict[str, Any]]:
    """Build the full ordered system template library."""
    by_id = {
        meta["id"]: meta
        for meta in (
            LEGACY_TEMPLATES
            + NEW_MODULAR_TEMPLATES
            + TRANSPORT_TEMPLATES
            + TRIP_TYPE_TEMPLATES
            + TRAVELLER_TEMPLATES
        )
    }

    ordered_ids = [
        # Transport
        "sys_tpl_car_travel",
        "sys_tpl_air_travel",
        "sys_tpl_train_bus",
        "sys_tpl_motorcycle",
        "sys_tpl_bicycle",
        "sys_tpl_camper",
        # Essentials
        "sys_tpl_basic_trip",
        "sys_tpl_documents",
        "sys_tpl_clothing",
        "sys_tpl_toiletries",
        "sys_tpl_health",
        "sys_tpl_electronics",
        "sys_tpl_food_drinks",
        # Trip type
        "sys_tpl_beach",
        "sys_tpl_mountains",
        "sys_tpl_camping",
        "sys_tpl_business",
        "sys_tpl_summer",
        "sys_tpl_winter",
        # Travellers
        "sys_tpl_with_child",
        "sys_tpl_with_baby",
        "sys_tpl_with_pet",
        "sys_tpl_with_cat",
        # Before leaving
        "sys_tpl_home_prep",
        "sys_tpl_final_checks",
    ]

    templates: list[dict[str, Any]] = []
    for template_id in ordered_ids:
        if template_id == "sys_tpl_car_travel":
            templates.append(build_car_travel_template())
        else:
            templates.append(build_template(by_id[template_id]))
    return templates
