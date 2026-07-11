/// Builds Google Maps URLs for driving directions.
class GoogleMapsLaunchUtils {
  GoogleMapsLaunchUtils._();

  static Uri buildDrivingDirectionsUri({
    required String originCityName,
    required String destinationName,
  }) {
    return Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${Uri.encodeComponent(originCityName)}'
      '&destination=${Uri.encodeComponent(destinationName)}'
      '&travelmode=driving',
    );
  }
}
