import 'package:flutter/material.dart';

IconData resolvePackingTemplateIcon(String? iconKey) {
  switch (iconKey) {
    case 'luggage':
      return Icons.luggage_outlined;
    case 'flight':
      return Icons.flight_outlined;
    case 'directions_car':
      return Icons.directions_car_outlined;
    case 'directions_transit':
      return Icons.directions_transit_outlined;
    case 'beach_access':
      return Icons.beach_access_outlined;
    case 'terrain':
      return Icons.terrain_outlined;
    case 'camping':
      return Icons.forest_outlined;
    case 'work':
      return Icons.work_outline;
    case 'child_care':
      return Icons.child_care_outlined;
    case 'pets':
      return Icons.pets_outlined;
    default:
      return Icons.checklist_outlined;
  }
}
