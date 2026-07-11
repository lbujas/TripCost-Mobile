/// Vehicle categories used for vignettes, tolls, and speed limits (future).
enum VehicleType {
  motorcycle('motorcycle'),
  passengerCar('passengerCar'),
  passengerCarWithTrailer('passengerCarWithTrailer'),
  camper('camper'),
  vanUpTo35t('vanUpTo35t');

  const VehicleType(this.storageValue);

  final String storageValue;

  static const List<VehicleType> selectableValues = [
    VehicleType.motorcycle,
    VehicleType.passengerCar,
    VehicleType.passengerCarWithTrailer,
    VehicleType.camper,
    VehicleType.vanUpTo35t,
  ];

  static VehicleType fromStorage(String? value) {
    switch (value) {
      case 'motorcycle':
        return VehicleType.motorcycle;
      case 'passengerCarWithTrailer':
        return VehicleType.passengerCarWithTrailer;
      case 'camper':
        return VehicleType.camper;
      case 'vanUpTo35t':
        return VehicleType.vanUpTo35t;
      case 'passengerCar':
      default:
        return VehicleType.passengerCar;
    }
  }
}
