/// Temporary release-visible ad diagnostics for Play/internal test auditing.
void adAuditLog(String message) {
  // ignore: avoid_print
  print('[TripCostAds] $message');
}
