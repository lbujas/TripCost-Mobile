/// Supported car fuel types for trip planning (no electric/hybrid yet).
enum CarFuelType {
  petrol95('petrol95'),
  diesel('diesel'),
  lpg('lpg');

  const CarFuelType(this.storageValue);

  final String storageValue;

  static const List<CarFuelType> selectableValues = [
    CarFuelType.petrol95,
    CarFuelType.diesel,
    CarFuelType.lpg,
  ];

  static CarFuelType fromStorage(String? value) {
    switch (value?.toLowerCase()) {
      case 'diesel':
        return CarFuelType.diesel;
      case 'lpg':
        return CarFuelType.lpg;
      case 'petrol95':
      case 'pb95':
        return CarFuelType.petrol95;
      default:
        return CarFuelType.petrol95;
    }
  }
}
