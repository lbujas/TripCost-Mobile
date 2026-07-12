import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_checkbox_mode.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list_export_data.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_options.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_page_orientation.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_scope.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_priority.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/services/packing_pdf_fonts.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/services/packing_pdf_labels.dart';

class PackingListPdfService {
  PackingListPdfService(this._fonts);

  final PackingPdfFonts _fonts;

  Future<Uint8List> generate({
    required PackingListExportData data,
    required PackingPdfOptions options,
    required PackingPdfLabels labels,
  }) async {
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: _fonts.regular,
        bold: _fonts.bold,
        italic: _fonts.regular,
        boldItalic: _fonts.bold,
      ),
    );

    final pageFormat = _pageFormat(options);
    final textColor = options.blackAndWhite ? PdfColors.black : PdfColors.black;
    final mutedColor =
        options.blackAndWhite ? PdfColors.grey700 : PdfColors.grey700;
    final dateFormat = DateFormat.yMMMd();

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 48),
        footer: (context) {
          return pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              labels.formatPage(context.pageNumber, context.pagesCount),
              style: pw.TextStyle(fontSize: 9, color: mutedColor),
            ),
          );
        },
        build: (context) {
          final widgets = <pw.Widget>[
            _buildHeader(
              data: data,
              options: options,
              labels: labels,
              dateFormat: dateFormat,
              textColor: textColor,
              mutedColor: mutedColor,
            ),
            pw.SizedBox(height: 16),
          ];

          var isFirstCategory = true;
          for (final category in data.categories) {
            if (options.startEachCategoryOnNewPage && !isFirstCategory) {
              widgets.add(pw.NewPage());
            }
            isFirstCategory = false;

            widgets.addAll(
              _buildCategorySection(
                category: category,
                options: options,
                labels: labels,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
            );
          }

          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 12),
              child: pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  labels.appName,
                  style: pw.TextStyle(fontSize: 8, color: mutedColor),
                ),
              ),
            ),
          );

          return widgets;
        },
      ),
    );

    return doc.save();
  }

  PdfPageFormat _pageFormat(PackingPdfOptions options) {
    if (options.pageOrientation == PackingPdfPageOrientation.landscape) {
      return PdfPageFormat.a4.landscape;
    }
    return PdfPageFormat.a4;
  }

  pw.Widget _buildHeader({
    required PackingListExportData data,
    required PackingPdfOptions options,
    required PackingPdfLabels labels,
    required DateFormat dateFormat,
    required PdfColor textColor,
    required PdfColor mutedColor,
  }) {
    final summaryLines = <String>[
      labels.formatTotalItems(data.totalItems),
      if (data.scope == PackingPdfScope.shoppingList)
        labels.formatPurchasedItems(data.checkedCount)
      else if (data.scope != PackingPdfScope.unpackedOnly)
        labels.formatPackedItems(data.checkedCount),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          labels.packingListTitle,
          style: pw.TextStyle(
            fontSize: 11,
            color: mutedColor,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          data.listName,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: textColor,
          ),
        ),
        if (options.showDescription &&
            data.description != null &&
            data.description!.trim().isNotEmpty) ...[
          pw.SizedBox(height: 6),
          pw.Text(
            '${labels.descriptionLabel}: ${data.description!.trim()}',
            style: pw.TextStyle(fontSize: 10, color: textColor),
          ),
        ],
        if (options.showDepartureAndReturnDates &&
            (data.departureDate != null || data.returnDate != null)) ...[
          pw.SizedBox(height: 6),
          if (data.departureDate != null)
            pw.Text(
              '${labels.departureDate}: ${dateFormat.format(data.departureDate!)}',
              style: pw.TextStyle(fontSize: 10, color: textColor),
            ),
          if (data.returnDate != null)
            pw.Text(
              '${labels.returnDate}: ${dateFormat.format(data.returnDate!)}',
              style: pw.TextStyle(fontSize: 10, color: textColor),
            ),
        ],
        pw.SizedBox(height: 8),
        pw.Text(
          '${labels.generatedOn} ${dateFormat.format(data.generatedAt)}',
          style: pw.TextStyle(fontSize: 9, color: mutedColor),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          summaryLines.join('  |  '),
          style: pw.TextStyle(fontSize: 10, color: textColor),
        ),
        pw.Divider(color: mutedColor, height: 24),
      ],
    );
  }

  List<pw.Widget> _buildCategorySection({
    required PackingExportCategoryGroup category,
    required PackingPdfOptions options,
    required PackingPdfLabels labels,
    required PdfColor textColor,
    required PdfColor mutedColor,
  }) {
    return [
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8, top: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              child: pw.Text(
                category.name,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            pw.Text(
              '${category.checkedCount}/${category.itemCount}',
              style: pw.TextStyle(fontSize: 10, color: mutedColor),
            ),
          ],
        ),
      ),
      for (final item in category.items)
        _buildItemRow(
          item: item,
          options: options,
          labels: labels,
          textColor: textColor,
          mutedColor: mutedColor,
        ),
      pw.SizedBox(height: 12),
    ];
  }

  pw.Widget _buildItemRow({
    required PackingExportItemRow item,
    required PackingPdfOptions options,
    required PackingPdfLabels labels,
    required PdfColor textColor,
    required PdfColor mutedColor,
  }) {
    final checked =
        options.checkboxMode == PackingCheckboxMode.currentState &&
        item.isChecked;

    final metaParts = <String>[];
    if (options.showQuantity) {
      final quantityLabel = _formatQuantity(item.quantity, item.unit);
      if (quantityLabel.isNotEmpty) {
        metaParts.add(quantityLabel);
      }
    }
    if (options.showPriority && item.priority != PackingPriority.normal) {
      metaParts.add(_priorityLabel(item.priority, labels));
    }
    if (options.showPurchaseStatus && item.needsPurchase) {
      metaParts.add(labels.toBuy);
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildCheckbox(checked: checked, color: textColor),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  item.name,
                  style: pw.TextStyle(fontSize: 12, color: textColor),
                ),
                if (metaParts.isNotEmpty)
                  pw.Text(
                    metaParts.join('  |  '),
                    style: pw.TextStyle(fontSize: 9, color: mutedColor),
                  ),
                if (options.showNotes &&
                    item.note != null &&
                    item.note!.trim().isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 2),
                    child: pw.Text(
                      item.note!.trim(),
                      style: pw.TextStyle(fontSize: 9, color: mutedColor),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCheckbox({required bool checked, required PdfColor color}) {
    return pw.Container(
      width: 16,
      height: 16,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1.5),
      ),
      child:
          checked
              ? pw.CustomPaint(
                size: const PdfPoint(16, 16),
                painter: (canvas, size) {
                  canvas
                    ..setStrokeColor(color)
                    ..setLineWidth(1.5)
                    ..moveTo(3, 8)
                    ..lineTo(7, 12)
                    ..lineTo(13, 4)
                    ..strokePath();
                },
              )
              : null,
    );
  }

  String _formatQuantity(int quantity, String unit) {
    if (quantity <= 0) {
      return '';
    }

    final quantityText = quantity.toString();

    if (unit.trim().isEmpty || unit == 'piece') {
      return quantityText == '1' ? '' : '× $quantityText';
    }

    return '× $quantityText $unit';
  }

  String _priorityLabel(PackingPriority priority, PackingPdfLabels labels) {
    switch (priority) {
      case PackingPriority.important:
        return labels.important;
      case PackingPriority.critical:
        return labels.critical;
      case PackingPriority.normal:
        return '';
    }
  }
}
