import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_toll_matrix_entry.dart';

void main() {
  test('fromJson parses matrix entry with accuracy', () {
    final entry = CroatiaTollMatrixEntry.fromJson({
      'id': 'hr_gorican_rijeka_cat_i',
      'entryGateId': 'gorican',
      'exitGateId': 'rijeka',
      'vehicleCategory': 'I',
      'amount': 9.7,
      'currency': 'EUR',
      'lastVerified': '2026-06-10',
      'accuracy': 'verified',
    });

    expect(entry.entryGateId, 'gorican');
    expect(entry.exitGateId, 'rijeka');
    expect(entry.isEstimated, isFalse);
  });
}
