#!/usr/bin/env dart

// Run this script to generate the PDF report:
// dart run tool/generate_report.dart

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> main() async {
  print('🔄 Generating MedAdhere Project Report...');
  
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        // ============ SECTION 1: TITLE & TEAM INFO ============
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'MedAdhere',
                style: pw.TextStyle(
                  fontSize: 48,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor(0.1, 0.5, 0.8),
                ),
              ),
            ),
            pw.Center(
              child: pw.Text(
                'Medication Adherence Tracking System',
                style: pw.TextStyle(
                  fontSize: 18,
                  color: PdfColor(0.3, 0.3, 0.3),
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 20),
            pw.Text(
              'Project Report - May 2026',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Team Information',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              '• Project Lead: Development Team',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.Text(
              '• Version: 1.0.0+1',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.Text(
              '• Framework: Flutter 3.9.2',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.Text(
              '• Supported Platforms: Android, iOS, Windows, Web, Linux, macOS',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.Text(
              '• Supported Languages: English, Zulu, Xhosa',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 30),

            // ============ SECTION 2: PROBLEM STATEMENT & TARGET USERS ============
            pw.Text(
              '2. Problem Statement & Target Users',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor(0.1, 0.5, 0.8),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Problem Statement',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Medication non-adherence is a critical healthcare challenge in Southern Africa, '
              'particularly for chronic conditions. Patients struggle to remember medication schedules, '
              'leading to poor health outcomes and increased hospitalizations. Healthcare workers lack real-time '
              'visibility into patient adherence patterns, making it difficult to intervene early.',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Target Users',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              '1. Patients: Individuals managing chronic conditions (diabetes, hypertension, etc.)',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.Text(
              '2. Healthcare Workers: Clinic staff and community health workers',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.Text(
              '3. Caregivers: Family members supporting patient medication adherence',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.Text(
              '4. Geographic Focus: Southern Africa (primary), with multi-language support',
              style: const pw.TextStyle(fontSize: 11),
            ),
          ],
        ),
      ],
    ),
  );

  // PAGE 2: IMPLEMENTED FEATURES
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        pw.Text(
          '3. Implemented Features',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor(0.1, 0.5, 0.8),
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          'Patient Features (✅ Implemented)',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text('• Home Dashboard: View upcoming medications and adherence status at a glance', style: const pw.TextStyle(fontSize: 11)),
        pw.Text('• Medication Tracking: Log medication intake with detailed dose information', style: const pw.TextStyle(fontSize: 11)),
        pw.Text('• Adherence Calendar: Visual month-view calendar showing medication adherence history', style: const pw.TextStyle(fontSize: 11)),
        pw.Text('• Risk Assessment: Real-time risk level monitoring with visual indicators (Low/Medium/High)', style: const pw.TextStyle(fontSize: 11)),
        pw.Text('• Multi-Language Support: Interface available in English, Zulu, and Xhosa', style: const pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 12),
        pw.Text('Healthcare Worker Features (✅ Implemented)', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('• Worker Dashboard: Overview of clinic statistics and patient metrics with charts', style: const pw.TextStyle(fontSize: 11)),
        pw.Text('• Patient List: Browse clinic patients with visual risk indicators', style: const pw.TextStyle(fontSize: 11)),
        pw.Text('• Risk Overview: Monitor patient risk levels with visual charts and analytics', style: const pw.TextStyle(fontSize: 11)),
      ],
    ),
  );

  // Save the PDF
  final file = File('MedAdhere_Project_Report_May2026.pdf');
  await file.writeAsBytes(await pdf.save());

  print('✅ Report generated successfully!');
  print('📁 Location: ${file.absolute.path}');
}
