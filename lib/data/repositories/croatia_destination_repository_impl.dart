import 'package:travel_cost_planner_europe/data/sources/croatia_destination_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/croatia_region_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/croatia_toll_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_destination.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_region.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_toll.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_destination_repository.dart';

class CroatiaDestinationRepositoryImpl implements CroatiaDestinationRepository {
  CroatiaDestinationRepositoryImpl(
    this._destinationSource,
    this._regionSource,
    this._tollSource,
  );

  final CroatiaDestinationLocalSource _destinationSource;
  final CroatiaRegionLocalSource _regionSource;
  final CroatiaTollLocalSource _tollSource;

  @override
  Future<List<CroatiaDestination>> getAllDestinations() {
    return _destinationSource.getDestinations();
  }

  @override
  Future<CroatiaDestination?> getDestinationById(String id) async {
    final destinations = await getAllDestinations();
    for (final destination in destinations) {
      if (destination.id == id) {
        return destination;
      }
    }
    return null;
  }

  @override
  Future<List<CroatiaDestination>> getPopularDestinations() async {
    final destinations = await getAllDestinations();
    return destinations.where((destination) => destination.popular).toList();
  }

  @override
  Future<CroatiaRegion?> getRegionForDestination(
    CroatiaDestination destination,
  ) async {
    final regions = await _regionSource.getRegions();
    for (final region in regions) {
      if (region.id == destination.regionId) {
        return region;
      }
    }
    return null;
  }

  @override
  Future<CroatiaToll?> getTollForDestination(
    CroatiaDestination destination,
  ) async {
    final region = await getRegionForDestination(destination);
    if (region == null) {
      return null;
    }

    final tolls = await _tollSource.getTolls();
    for (final toll in tolls) {
      if (toll.id == region.defaultTollId) {
        return toll;
      }
    }
    return null;
  }

  Future<List<String>> getRecentDestinationIds() {
    return _destinationSource.getRecentDestinationIds();
  }

  Future<void> addRecentDestination(String destinationId) {
    return _destinationSource.addRecentDestination(destinationId);
  }
}
