import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// Thrown when required Noto Sans PDF fonts cannot be loaded from assets.
class PackingPdfFontsException implements Exception {
  PackingPdfFontsException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PackingPdfFonts {
  const PackingPdfFonts({required this.regular, required this.bold});

  final pw.Font regular;
  final pw.Font bold;

  static const regularAsset = 'assets/fonts/NotoSans-Regular.ttf';
  static const boldAsset = 'assets/fonts/NotoSans-Bold.ttf';

  static Future<PackingPdfFonts> load() async {
    try {
      final regularData = await rootBundle.load(regularAsset);
      final boldData = await rootBundle.load(boldAsset);

      return PackingPdfFonts(
        regular: pw.Font.ttf(regularData),
        bold: pw.Font.ttf(boldData),
      );
    } on FlutterError catch (error) {
      throw PackingPdfFontsException(
        'Required PDF fonts are missing from the application bundle. '
        'Add $regularAsset and $boldAsset to assets/fonts/. '
        'Run: dart run tool/download_pdf_fonts.dart. '
        'Details: ${error.message}',
      );
    } catch (error) {
      throw PackingPdfFontsException(
        'Failed to load required PDF fonts ($regularAsset, $boldAsset): $error',
      );
    }
  }
}
