import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/services/packing_pdf_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PackingPdfFonts', () {
    test('loads Noto Sans regular and bold from assets', () async {
      final fonts = await PackingPdfFonts.load();

      expect(fonts.regular, isNotNull);
      expect(fonts.bold, isNotNull);
    });
  });
}
