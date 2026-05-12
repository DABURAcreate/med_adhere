import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// These match the shapes used in report_screen.dart.
// In production, drive these from report_repository.dart.
// ─────────────────────────────────────────────────────────────────────────────

enum ReportType { perPatient, perClinic }
enum ExportFormat { pdf, csv }

class ReportRow {
  final String date;
  final String subject; // medication name (per-patient) or patient name (per-clinic)
  final int taken;
  final int missed;
  final double adherence;

  const ReportRow({
    required this.date,
    required this.subject,
    required this.taken,
    required this.missed,
    required this.adherence,
  });

  /// CSV line
  String toCsvLine() =>
      '"$date","$subject",$taken,$missed,${adherence.toStringAsFixed(1)}';
}

class ReportConfig {
  final ReportType type;
  final ExportFormat format;
  final String? patientName;   // null for per-clinic
  final String? patientCode;
  final String clinicName;
  final DateTime startDate;
  final DateTime endDate;
  final List<ReportRow> rows;

  const ReportConfig({
    required this.type,
    required this.format,
    this.patientName,
    this.patientCode,
    required this.clinicName,
    required this.startDate,
    required this.endDate,
    required this.rows,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class ReportExportService {
  ReportExportService._();
  static final instance = ReportExportService._();

  // Colour constants (matching the app palette for the PDF header)
  static const _navy = PdfColor.fromInt(0xFF114C90);
  static const _teal = PdfColor.fromInt(0xFF1A7E95);
  static const _lightBlue = PdfColor.fromInt(0xFFF0F5FB);
  static const _danger = PdfColor.fromInt(0xFFB91C1C);
  static const _success = PdfColor.fromInt(0xFF16A34A);
  static const _warning = PdfColor.fromInt(0xFFD97706);
  static const _grey = PdfColor.fromInt(0xFF6B7280);

  // ── Public entry point ──────────────────────────────────────────────────
  /// Call this from report_screen.dart after generating preview data.
  ///
  /// Example:
  /// ```dart
  /// await ReportExportService.instance.export(
  ///   config: ReportConfig(
  ///     type: ReportType.perPatient,
  ///     format: ExportFormat.pdf,
  ///     patientName: 'Sipho Dlamini',
  ///     patientCode: 'MBM-0041',
  ///     clinicName: 'Mbombela Clinic',
  ///     startDate: _startDate,
  ///     endDate: _endDate,
  ///     rows: _previewRows,
  ///   ),
  ///   context: context,
  /// );
  /// ```
  Future<void> export({
    required ReportConfig config,
    required BuildContext context,
  }) async {
    try {
      final File file;

      if (config.format == ExportFormat.pdf) {
        file = await _buildPdf(config);
      } else {
        file = await _buildCsv(config);
      }

      await _share(file, config, context);
    } catch (e, stack) {
      debugPrint('ReportExportService error: $e\n$stack');
      if (context.mounted) {
        _showError(context, e.toString());
      }
    }
  }

  // ── PDF builder ─────────────────────────────────────────────────────────
  Future<File> _buildPdf(ReportConfig config) async {
    final doc = pw.Document();
    final dateFormatter = DateFormat('d MMM yyyy');
    final now = DateFormat('d MMM yyyy, HH:mm').format(DateTime.now());

    // Summary stats
    final totalTaken = config.rows.fold(0, (s, r) => s + r.taken);
    final totalMissed = config.rows.fold(0, (s, r) => s + r.missed);
    final avgAdherence = config.rows.isEmpty
        ? 0.0
        : config.rows.fold(0.0, (s, r) => s + r.adherence) /
        config.rows.length;

    // Column header label
    final subjectHeader =
    config.type == ReportType.perPatient ? 'Medication' : 'Patient';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _pdfHeader(config, dateFormatter, now),
        footer: (context) => _pdfFooter(context, now),
        build: (context) => [
          // ── Summary stat boxes ──
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              _statBox('Total Taken', '$totalTaken', _success),
              pw.SizedBox(width: 8),
              _statBox('Total Missed', '$totalMissed', _danger),
              pw.SizedBox(width: 8),
              _statBox(
                'Avg Adherence',
                '${avgAdherence.toStringAsFixed(1)}%',
                _adherencePdfColor(avgAdherence),
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // ── Change note ──
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFFFFBEB),
              border: pw.Border.all(
                  color: const PdfColor.fromInt(0xFFFDE68A)),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              children: [
                pw.Text('ℹ  ',
                    style: pw.TextStyle(
                        color: _warning, fontSize: 10)),
                pw.Expanded(
                  child: pw.Text(
                    'Changes apply to future doses only. Past logs are not modified.',
                    style: pw.TextStyle(
                        fontSize: 9, color: _warning),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // ── Data table ──
          pw.TableHelper.fromTextArray(
            headers: ['Date', subjectHeader, 'Taken', 'Missed', 'Adh. %'],
            data: config.rows
                .map((r) => [
              r.date,
              r.subject,
              '${r.taken}',
              '${r.missed}',
              '${r.adherence.toStringAsFixed(1)}%',
            ])
                .toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 9,
            ),
            headerDecoration:
            const pw.BoxDecoration(color: _navy),
            cellStyle: const pw.TextStyle(fontSize: 9),
            rowDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFF9FAFB)),
            oddRowDecoration:
            const pw.BoxDecoration(color: PdfColors.white),
            border: pw.TableBorder.all(
                color: const PdfColor.fromInt(0xFFE5E7EB),
                width: 0.5),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
            },
            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(2.5),
              2: const pw.FlexColumnWidth(0.8),
              3: const pw.FlexColumnWidth(0.8),
              4: const pw.FlexColumnWidth(0.9),
            },
          ),
        ],
      ),
    );

    return _saveFile(
      bytes: await doc.save(),
      filename: _buildFilename(config, 'pdf'),
    );
  }

  // ── PDF sub-widgets ─────────────────────────────────────────────────────
  pw.Widget _pdfHeader(
      ReportConfig config, DateFormat fmt, String now) {
    final scope = config.type == ReportType.perPatient
        ? '${config.patientName} (${config.patientCode})'
        : config.clinicName;
    final rangeStr =
        '${fmt.format(config.startDate)} – ${fmt.format(config.endDate)}';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Gradient-style header bar (simulate with a solid box)
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          decoration: const pw.BoxDecoration(
            color: _navy,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'MedAdhere — Adherence Report',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    scope,
                    style: const pw.TextStyle(
                        color: PdfColor.fromInt(0xFFBFDBFE),
                        fontSize: 9),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(rangeStr,
                      style: const pw.TextStyle(
                          color: PdfColors.white, fontSize: 9)),
                  pw.SizedBox(height: 3),
                  pw.Text('Generated: $now',
                      style: const pw.TextStyle(
                          color: PdfColor.fromInt(0xFFBFDBFE),
                          fontSize: 8)),
                ],
              ),
            ],
          ),
        ),
        // Teal accent bar
        pw.Container(
          height: 3,
          color: _teal,
        ),
        pw.SizedBox(height: 8),
      ],
    );
  }

  pw.Widget _pdfFooter(pw.Context context, String now) => pw.Column(
    children: [
      pw.Divider(color: const PdfColor.fromInt(0xFFE5E7EB)),
      pw.SizedBox(height: 4),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'CONFIDENTIAL — Worker use only',
            style: const pw.TextStyle(
                fontSize: 7, color: _grey),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(
                fontSize: 7, color: _grey),
          ),
        ],
      ),
    ],
  );

  pw.Widget _statBox(String label, String value, PdfColor color) =>
      pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(
              vertical: 10, horizontal: 8),
          decoration: pw.BoxDecoration(
            color: PdfColor(
                color.red, color.green, color.blue, 0.08),
            border: pw.Border.all(
                color: PdfColor(
                    color.red, color.green, color.blue, 0.3),
                width: 0.8),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            children: [
              pw.Text(value,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: color,
                  )),
              pw.SizedBox(height: 4),
              pw.Text(label,
                  style: const pw.TextStyle(
                      fontSize: 8, color: _grey)),
            ],
          ),
        ),
      );

  PdfColor _adherencePdfColor(double v) =>
      v >= 80 ? _success : v >= 60 ? _warning : _danger;

  // ── CSV builder ─────────────────────────────────────────────────────────
  Future<File> _buildCsv(ReportConfig config) async {
    final fmt = DateFormat('d MMM yyyy');
    final subjectHeader =
    config.type == ReportType.perPatient ? 'Medication' : 'Patient';
    final scope = config.type == ReportType.perPatient
        ? '${config.patientName} (${config.patientCode})'
        : config.clinicName;

    final buffer = StringBuffer();

    // Meta header block
    buffer.writeln('# MedAdhere Adherence Report');
    buffer.writeln('# Generated: ${DateFormat('d MMM yyyy HH:mm').format(DateTime.now())}');
    buffer.writeln('# Scope: $scope');
    buffer.writeln(
        '# Period: ${fmt.format(config.startDate)} to ${fmt.format(config.endDate)}');
    buffer.writeln('# CONFIDENTIAL — Worker use only');
    buffer.writeln();

    // Column headers
    buffer.writeln('"Date","$subjectHeader","Taken","Missed","Adherence %"');

    // Data rows
    for (final row in config.rows) {
      buffer.writeln(row.toCsvLine());
    }

    // Summary footer
    final totalTaken = config.rows.fold(0, (s, r) => s + r.taken);
    final totalMissed = config.rows.fold(0, (s, r) => s + r.missed);
    final avg = config.rows.isEmpty
        ? 0.0
        : config.rows.fold(0.0, (s, r) => s + r.adherence) /
        config.rows.length;
    buffer.writeln();
    buffer.writeln('"TOTAL","","$totalTaken","$totalMissed","${avg.toStringAsFixed(1)}%"');

    return _saveFile(
      bytes: Uint8List.fromList(buffer.toString().codeUnits),
      filename: _buildFilename(config, 'csv'),
    );
  }

  // ── File helpers ────────────────────────────────────────────────────────
  Future<File> _saveFile({
    required Uint8List bytes,
    required String filename,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  String _buildFilename(ReportConfig config, String ext) {
    final fmt = DateFormat('yyyyMMdd');
    final scope = config.type == ReportType.perPatient
        ? config.patientCode ?? 'patient'
        : 'clinic';
    final start = fmt.format(config.startDate);
    final end = fmt.format(config.endDate);
    return 'medadhere_${scope}_${start}_${end}.$ext';
  }

  // ── Share ───────────────────────────────────────────────────────────────
  Future<void> _share(
      File file,
      ReportConfig config,
      BuildContext context,
      ) async {
    final mimeType = config.format == ExportFormat.pdf
        ? 'application/pdf'
        : 'text/csv';

    final label = config.format == ExportFormat.pdf ? 'PDF' : 'CSV';
    final scope = config.type == ReportType.perPatient
        ? config.patientName ?? 'Patient'
        : config.clinicName;

    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType)],
      subject: 'MedAdhere Adherence Report — $scope',
      text: 'Please find the attached $label adherence report for $scope.',
    );
  }

  // ── Error dialog ────────────────────────────────────────────────────────
  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded,
                color: Color(0xFFB91C1C), size: 20),
            SizedBox(width: 8),
            Text('Export Failed',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF114C90))),
          ],
        ),
        content: Text(
          'Could not generate report: $message',
          style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF165B9E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('OK',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}