import 'package:travel_cost_planner_europe/domain/models/croatia_destination.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_region.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_toll.dart';

abstract class CroatiaDestinationRepository {
  Future<List<CroatiaDestination>> getAllDestinations();

  Future<CroatiaDestination?> getDestinationById(String id);

  Future<List<CroatiaDestination>> getPopularDestinations();

  Future<CroatiaRegion?> getRegionForDestination(CroatiaDestination destination);

  Future<CroatiaToll?> getTollForDestination(CroatiaDestination destination);
}
