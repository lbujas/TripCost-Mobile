enum TripDirection {
  oneWay,
  roundTrip;

  int get tollMultiplier => switch (this) {
        TripDirection.oneWay => 1,
        TripDirection.roundTrip => 2,
      };

  static TripDirection fromJson(String value) {
    return switch (value) {
      'oneWay' => TripDirection.oneWay,
      _ => TripDirection.roundTrip,
    };
  }

  String toJson() => name;
}
