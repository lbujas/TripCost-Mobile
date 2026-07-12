import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_options.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_list_export_data_builder.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/services/packing_pdf_labels.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/services/packing_pdf_labels_mapper.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';

class PackingPdfPreviewScreen extends ConsumerStatefulWidget {
  const PackingPdfPreviewScreen({
    super.key,
    required this.list,
    required this.options,
    this.generatedPdf,
  });

  final PackingList list;
  final PackingPdfOptions options;
  final Uint8List? generatedPdf;

  @override
  ConsumerState<PackingPdfPreviewScreen> createState() =>
      _PackingPdfPreviewScreenState();
}

class _PackingPdfPreviewScreenState
    extends ConsumerState<PackingPdfPreviewScreen> {
  static const _builder = PackingListExportDataBuilder();
  Uint8List? _cachedPdf;

  @override
  void initState() {
    super.initState();
    _cachedPdf = widget.generatedPdf;
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final cachedPdf = _cachedPdf;
    if (cachedPdf != null) {
      return cachedPdf;
    }

    final l10n = AppLocalizations.of(context);
    final service = await ref.read(packingListPdfServiceProvider.future);
    final labels = packingPdfLabelsFromL10n(l10n);
    final exportData = _builder.build(
      list: widget.list,
      options: widget.options,
    );

    final generatedPdf = await service.generate(
      data: exportData,
      options: widget.options,
      labels: labels,
    );
    _cachedPdf = generatedPdf;
    return generatedPdf;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fileName = '${sanitizePackingPdfFilename(widget.list.name)}.pdf';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.packingPdfPreview),
        actions: const [SettingsActionButton()],
      ),
      body: PdfPreview(
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: fileName,
        build: _buildPdf,
        onError: (context, error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.packingPdfGenerationFailed),
            ),
          );
        },
      ),
    );
  }
}
