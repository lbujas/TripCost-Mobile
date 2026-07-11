/// Formatting helpers for distance, duration, and currency.
class Formatters {
  Formatters._();

  static String formatPln(double value) => '${value.toStringAsFixed(2)} PLN';

  static String formatDistanceKm(double distanceKm) =>
      '${distanceKm.toStringAsFixed(0)} km';

  static String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String formatDuration(int durationMinutes) {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    if (minutes == 0) {
      return '$hours h';
    }

    return '$hours h $minutes min';
  }
}
