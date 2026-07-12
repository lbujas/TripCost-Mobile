import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/localization/packing_template_localization_transport.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/localization/packing_template_localization_modular.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/localization/packing_template_localization_road_trip.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_list_from_templates_service.dart';

/// Resolves system template localization keys into user-visible strings.
String resolvePackingTemplateKey(AppLocalizations l10n, String key) {
  final roadTrip = resolveRoadTripPackingTemplateKey(l10n, key);
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
  }

  switch (key) {
    case 'packingTemplateBasicTrip':
      return l10n.packingTemplateBasicTrip;
    case 'packingTemplateBasicTripDesc':
      return l10n.packingTemplateBasicTripDesc;
    case 'packingTemplateAirTravel':
      return l10n.packingTemplateAirTravel;
    case 'packingTemplateAirTravelDesc':
      return l10n.packingTemplateAirTravelDesc;
    case 'packingTemplateCarTravel':
      return l10n.packingTemplateCarTravel;
    case 'packingTemplateCarTravelDesc':
      return l10n.packingTemplateCarTravelDesc;
    case 'packingTemplateTrainBusTravel':
      return l10n.packingTemplateTrainBusTravel;
    case 'packingTemplateTrainBusTravelDesc':
      return l10n.packingTemplateTrainBusTravelDesc;
    case 'packingTemplateBeach':
      return l10n.packingTemplateBeach;
    case 'packingTemplateBeachDesc':
      return l10n.packingTemplateBeachDesc;
    case 'packingTemplateMountains':
      return l10n.packingTemplateMountains;
    case 'packingTemplateMountainsDesc':
      return l10n.packingTemplateMountainsDesc;
    case 'packingTemplateCamping':
      return l10n.packingTemplateCamping;
    case 'packingTemplateCampingDesc':
      return l10n.packingTemplateCampingDesc;
    case 'packingTemplateBusinessTrip':
      return l10n.packingTemplateBusinessTrip;
    case 'packingTemplateBusinessTripDesc':
      return l10n.packingTemplateBusinessTripDesc;
    case 'packingTemplateTravellingWithChild':
      return l10n.packingTemplateTravellingWithChild;
    case 'packingTemplateTravellingWithChildDesc':
      return l10n.packingTemplateTravellingWithChildDesc;
    case 'packingTemplateTravellingWithPet':
      return l10n.packingTemplateTravellingWithPet;
    case 'packingTemplateTravellingWithPetDesc':
      return l10n.packingTemplateTravellingWithPetDesc;
    case 'packingTemplateGroupTransport':
      return l10n.packingTemplateGroupTransport;
    case 'packingTemplateGroupEssentials':
      return l10n.packingTemplateGroupEssentials;
    case 'packingTemplateGroupTripType':
      return l10n.packingTemplateGroupTripType;
    case 'packingTemplateGroupTravellers':
      return l10n.packingTemplateGroupTravellers;
    case 'packingTemplateGroupBeforeLeaving':
      return l10n.packingTemplateGroupBeforeLeaving;
    case 'packingTemplateCategoryDocuments':
      return l10n.packingTemplateCategoryDocuments;
    case 'packingTemplateCategoryClothing':
      return l10n.packingTemplateCategoryClothing;
    case 'packingTemplateCategoryToiletries':
      return l10n.packingTemplateCategoryToiletries;
    case 'packingTemplateCategoryElectronics':
      return l10n.packingTemplateCategoryElectronics;
    case 'packingTemplateCategoryHealth':
      return l10n.packingTemplateCategoryHealth;
    case 'packingTemplateCategoryFood':
      return l10n.packingTemplateCategoryFood;
    case 'packingTemplateCategoryTravelGear':
      return l10n.packingTemplateCategoryTravelGear;
    case 'packingTemplateCategoryOutdoor':
      return l10n.packingTemplateCategoryOutdoor;
    case 'packingTemplateCategoryBusiness':
      return l10n.packingTemplateCategoryBusiness;
    case 'packingTemplateCategoryChildCare':
      return l10n.packingTemplateCategoryChildCare;
    case 'packingTemplateCategoryPetCare':
      return l10n.packingTemplateCategoryPetCare;
    case 'packingTemplateCategoryBeachGear':
      return l10n.packingTemplateCategoryBeachGear;
    case 'packingTemplateItemIdentityDocument':
      return l10n.packingTemplateItemIdentityDocument;
    case 'packingTemplateItemWallet':
      return l10n.packingTemplateItemWallet;
    case 'packingTemplateItemPhoneCharger':
      return l10n.packingTemplateItemPhoneCharger;
    case 'packingTemplateItemMedicines':
      return l10n.packingTemplateItemMedicines;
    case 'packingTemplateItemWeatherAppropriateClothing':
      return l10n.packingTemplateItemWeatherAppropriateClothing;
    case 'packingTemplateItemToothbrush':
      return l10n.packingTemplateItemToothbrush;
    case 'packingTemplateItemPassport':
      return l10n.packingTemplateItemPassport;
    case 'packingTemplateItemBoardingPass':
      return l10n.packingTemplateItemBoardingPass;
    case 'packingTemplateItemHeadphones':
      return l10n.packingTemplateItemHeadphones;
    case 'packingTemplateItemTravelAdapter':
      return l10n.packingTemplateItemTravelAdapter;
    case 'packingTemplateItemDrivingLicense':
      return l10n.packingTemplateItemDrivingLicense;
    case 'packingTemplateItemCarDocuments':
      return l10n.packingTemplateItemCarDocuments;
    case 'packingTemplateItemFuelCard':
      return l10n.packingTemplateItemFuelCard;
    case 'packingTemplateItemRoadsideKit':
      return l10n.packingTemplateItemRoadsideKit;
    case 'packingTemplateItemSnacks':
      return l10n.packingTemplateItemSnacks;
    case 'packingTemplateItemTicket':
      return l10n.packingTemplateItemTicket;
    case 'packingTemplateItemWaterBottle':
      return l10n.packingTemplateItemWaterBottle;
    case 'packingTemplateItemSunscreen':
      return l10n.packingTemplateItemSunscreen;
    case 'packingTemplateItemSwimwear':
      return l10n.packingTemplateItemSwimwear;
    case 'packingTemplateItemTowel':
      return l10n.packingTemplateItemTowel;
    case 'packingTemplateItemSunglasses':
      return l10n.packingTemplateItemSunglasses;
    case 'packingTemplateItemSandals':
      return l10n.packingTemplateItemSandals;
    case 'packingTemplateItemHikingBoots':
      return l10n.packingTemplateItemHikingBoots;
    case 'packingTemplateItemWarmLayers':
      return l10n.packingTemplateItemWarmLayers;
    case 'packingTemplateItemRainJacket':
      return l10n.packingTemplateItemRainJacket;
    case 'packingTemplateItemFirstAidKit':
      return l10n.packingTemplateItemFirstAidKit;
    case 'packingTemplateItemTent':
      return l10n.packingTemplateItemTent;
    case 'packingTemplateItemSleepingBag':
      return l10n.packingTemplateItemSleepingBag;
    case 'packingTemplateItemCampingStove':
      return l10n.packingTemplateItemCampingStove;
    case 'packingTemplateItemFlashlight':
      return l10n.packingTemplateItemFlashlight;
    case 'packingTemplateItemLaptop':
      return l10n.packingTemplateItemLaptop;
    case 'packingTemplateItemBusinessCards':
      return l10n.packingTemplateItemBusinessCards;
    case 'packingTemplateItemFormalAttire':
      return l10n.packingTemplateItemFormalAttire;
    case 'packingTemplateItemNotebook':
      return l10n.packingTemplateItemNotebook;
    case 'packingTemplateItemDiapers':
      return l10n.packingTemplateItemDiapers;
    case 'packingTemplateItemBabyFood':
      return l10n.packingTemplateItemBabyFood;
    case 'packingTemplateItemFavoriteToy':
      return l10n.packingTemplateItemFavoriteToy;
    case 'packingTemplateItemPetCarrier':
      return l10n.packingTemplateItemPetCarrier;
    case 'packingTemplateItemPetFood':
      return l10n.packingTemplateItemPetFood;
    case 'packingTemplateItemLeash':
      return l10n.packingTemplateItemLeash;
    case 'packingTemplateItemPetWaterBowl':
      return l10n.packingTemplateItemPetWaterBowl;
    case 'packingTemplateItemPetHealthRecords':
      return l10n.packingTemplateItemPetHealthRecords;
    case 'packingTemplateUnitPiece':
      return l10n.packingTemplateUnitPiece;
    case 'packingTemplateUnitPair':
      return l10n.packingTemplateUnitPair;
    case 'packingTemplateUnitSet':
      return l10n.packingTemplateUnitSet;
    case 'packingTemplateUnitPack':
      return l10n.packingTemplateUnitPack;
    case 'packingTemplateNotePrescriptionMeds':
      return l10n.packingTemplateNotePrescriptionMeds;
    default:
      if (key.startsWith('packingTemplateCategory')) {
        return l10n.packingUnknownCategory;
      }
      if (key.startsWith('packingTemplateItem')) {
        return l10n.packingUnknownItem;
      }
      if (key.startsWith('packingTemplateUnit')) {
        return l10n.packingUnknownUnit;
      }
      return l10n.packingUnknownTemplate;
  }
}

String resolvePackingTemplateName(
  AppLocalizations l10n, {
  String? nameKey,
  String? customName,
}) {
  if (customName != null && customName.trim().isNotEmpty) {
    return customName.trim();
  }
  if (nameKey != null) {
    return resolvePackingTemplateKey(l10n, nameKey);
  }
  return l10n.packingUnknownTemplate;
}

String? resolvePackingTemplateDescription(
  AppLocalizations l10n, {
  String? descriptionKey,
  String? customDescription,
}) {
  if (customDescription != null && customDescription.trim().isNotEmpty) {
    return customDescription.trim();
  }
  if (descriptionKey != null) {
    return resolvePackingTemplateKey(l10n, descriptionKey);
  }
  return null;
}

PackingLocalizationResolver packingTemplateLocalizationResolver(
  AppLocalizations l10n,
) {
  return (String key) => resolvePackingTemplateKey(l10n, key);
}
