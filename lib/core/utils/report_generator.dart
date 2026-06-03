import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// Report generator for MedAdhere project
/// Generates comprehensive PDF reports with project details, features, and timeline
class ReportGenerator {
  static Future<File> generateProjectReport() async {
    final pdf = pw.Document();

    // Determine save location
    late String reportPath;
    
    if (defaultTargetPlatform == TargetPlatform.windows) {
      // Windows: Save to project root
      reportPath = 'MedAdhere_Project_Report_May2026.pdf';
    } else {
      // Other platforms: Use documents directory
      final output = await getApplicationDocumentsDirectory();
      reportPath = '${output.path}/MedAdhere_Project_Report_May2026.pdf';
    }

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

    // ============ PAGE 2: IMPLEMENTED FEATURES ============
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
          pw.Text(
            '• Home Dashboard: View upcoming medications and adherence status at a glance',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '• Medication Tracking: Log medication intake with detailed dose information',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '• Adherence Calendar: Visual month-view calendar showing medication adherence history',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '• Risk Assessment: Real-time risk level monitoring with visual indicators (Low/Medium/High)',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '• Multi-Language Support: Interface available in English, Zulu, and Xhosa',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Healthcare Worker Features (✅ Implemented)',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '• Worker Dashboard: Overview of clinic statistics and patient metrics with charts',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '• Patient List: Browse clinic patients with visual risk indicators',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '• Risk Overview: Monitor patient risk levels with visual charts and analytics',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Authentication & Security (✅ Implemented)',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '• Language Selection: Initial screen for choosing preferred language (EN/ZU/XH)',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '• PIN-Based Authentication: Secure patient login with PIN setup for new users',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '• Registration Code Verification: Code verification for new account creation',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Technical Implementation',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '• Navigation: GoRouter-based routing with named routes and nested navigation',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '• Localization: Full i18n support using intl package for 3 languages',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '• Responsive Design: Works on Android, iOS, Windows, Web, Linux, macOS',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '• Cross-Platform Support: Single codebase for all platforms',
            style: const pw.TextStyle(fontSize: 11),
          ),
        ],
      ),
    );

    // ============ PAGE 3: PENDING FEATURES & TIMELINE ============
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Text(
            '4. Pending Features for M5 (with Priorities & Timeline)',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor(0.1, 0.5, 0.8),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Priority 1: Critical Features (Week 1-2)',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor(0.8, 0.2, 0.2),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '1. Database Implementation (SQLite with drift ORM)',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '   - Define database tables for patients, medications, adherence records',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   - Implement DAOs for CRUD operations',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   - Status: Schema designed, implementation in progress',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor(0.8, 0.5, 0),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '2. Data Synchronization Engine',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '   - Offline-first architecture with automatic sync when online',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   - Conflict resolution for concurrent updates',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   - Status: Architecture designed, service structure started',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor(0.8, 0.5, 0),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '3. Push Notifications & SMS Fallback',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '   - Local notifications for medication reminders (timezone-aware)',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   - SMS fallback for feature phones',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   - Status: Service structure created, integration pending',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor(0.8, 0.5, 0),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Priority 2: Important Features (Week 3-4)',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor(0.8, 0.5, 0),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '4. Patient Management Module',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '   - Register new patients with clinic',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   - Schedule medications for patients',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   - Status: Screens created, backend logic pending',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor(0.8, 0.5, 0),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '5. Adherence Reports & PDF Export',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '   - Generate adherence reports by date range',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   - Export to PDF for healthcare worker review',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   - Status: Report generation utility started',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor(0.8, 0.5, 0),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '6. Encryption & Security Hardening',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '   - End-to-end encryption for sensitive data',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   - Secure local storage',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   - Status: Security module structure created',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor(0.8, 0.5, 0),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Priority 3: Enhancement Features (Week 5+)',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor(0.2, 0.6, 0.2),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '7. Advanced Risk Assessment Algorithm',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '   - Predictive risk scoring based on adherence patterns',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   - Status: Basic risk calculation in progress',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor(0.8, 0.5, 0),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '8. Follow-up Scheduling System',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '   - Schedule patient follow-ups with automated reminders',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   - Status: Screen structure created',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor(0.8, 0.5, 0),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '9. Caregiver Linking Module',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Text(
            '   - Allow caregivers to monitor patient adherence',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   - Status: Screen structure created',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor(0.8, 0.5, 0),
            ),
          ),
        ],
      ),
    );

    // ============ PAGE 4: SYSTEM DESIGN OVERVIEW ============
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Text(
            '5. System Design Overview',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor(0.1, 0.5, 0.8),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Architecture Overview',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'MedAdhere follows a clean architecture pattern with feature-driven modularization:',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Technology Stack',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Frontend: Flutter 3.9.2 (cross-platform)',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'State Management: Provider + multi-language support',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Database: SQLite with drift ORM',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Navigation: GoRouter with named routes',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Localization: intl package (EN, ZU, XH)',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Notifications: Local notifications + timezone support',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Networking: HTTP client with offline-first architecture',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Export: PDF generation for reports',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Project Structure',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'lib/',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            '  ├── app/                 # App config, routing, theming',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.Text(
            '  ├── core/                # Shared services (DB, network, notifications, security)',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.Text(
            '  ├── features/            # Feature modules (auth, patient, dashboard, reports)',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.Text(
            '  └── main.dart            # Entry point',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Core Modules',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '• core/database/ — SQLite tables, DAOs, migrations',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• core/network/ — API client, connectivity detection, sync engine',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• core/notifications/ — Local notifications, timezone support, reminders',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• core/security/ — PIN authentication, encryption, secure storage',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• core/sync/ — Offline-first synchronization, conflict resolution',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• core/sms/ — SMS gateway integration, fallback messaging',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• core/utils/ — Constants, helpers, report generation',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Feature Modules',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '• auth/ — Login, registration, PIN setup',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• patient/ — Home dashboard, medication tracking, calendar, risk view',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• dashboard/ — Worker stats, patient overview',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• patient_management/ — Register, schedule, follow-up',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• risk_assessment/ — Risk calculation engine',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• reports/ — Adherence reporting, PDF export',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• reminders/ — Notification settings, scheduling',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• caregiver/ — Caregiver linking and account management',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Data Flow',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '1. User interacts with UI (screens)',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '2. Events trigger business logic (services, repositories)',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '3. Data persisted to local SQLite database',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '4. Sync engine queues changes for backend',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '5. When online, sync sends/receives data, resolves conflicts',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '6. Notifications trigger based on schedules',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );

    // ============ PAGE 5: EVALUATION & RESULTS ============
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Text(
            '6. Evaluation Method & Results',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor(0.1, 0.5, 0.8),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Evaluation Methodology',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '1. Functionality Testing',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '   • Manual testing of all implemented screens and workflows',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   • Cross-platform compatibility (Android, iOS, Windows, Web, Linux, macOS)',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   • Navigation flow verification',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   • Language switching verification (EN, ZU, XH)',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '2. Usability Testing',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '   • User interface responsiveness and visual clarity',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   • Navigation intuitiveness (GoRouter implementation)',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   • Theme consistency across screens',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '3. Code Quality Metrics',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '   • Architecture adherence (clean architecture patterns)',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   • Modular design and feature isolation',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   • Code reusability and DRY principles',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '4. Performance Assessment',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '   • App startup time and screen load time',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   • Memory consumption monitoring',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   • Offline functionality verification',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Results Summary',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '✅ Current Implementation Status',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor(0.2, 0.6, 0.2),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '• 8 screens fully implemented with routing setup',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Multi-language UI framework operational',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Authentication flow structure complete',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Theme system with light/dark mode support',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Cross-platform project setup verified',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Key Improvements Achieved',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '1. Modular Architecture: Feature-based organization enables scalability',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '2. Cross-Platform Support: Single codebase for 6 platforms',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '3. Internationalization: Native support for 3+ languages',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '4. Clean Navigation: GoRouter eliminates navigation complexity',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '5. Responsive Design: Adapts to different screen sizes and orientations',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Upcoming Improvements (M5)',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '• Backend database integration for persistent storage',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Real-time push notifications and SMS reminders',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Advanced encryption and security hardening',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Predictive risk assessment algorithms',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Comprehensive adherence reporting and analytics',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );

    // ============ PAGE 6: LIMITATIONS & RISKS ============
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Text(
            '7. Known Limitations & Risk Mitigation',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor(0.1, 0.5, 0.8),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Known Limitations',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '1. Backend Integration Pending',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '   Current State: UI framework complete, API integration not yet implemented',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Impact: Data persistence is limited to local app state',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Timeline: Backend API integration planned for Week 1-2 of M5',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '2. Database Not Yet Initialized',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '   Current State: Schema defined, drift ORM integration pending',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Impact: No persistent local storage of patient/medication data',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Mitigation: Priority 1 task for M5, schema already reviewed',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '3. Notifications Not Fully Integrated',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '   Current State: Notification service structure created',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Impact: No medication reminders or SMS fallback yet',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Timeline: Week 3-4 of M5',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '4. No Encryption/Security Hardening Yet',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '   Current State: Security module skeleton created',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Impact: Sensitive data not encrypted at rest or in transit',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Mitigation: Priority 2 task, crypto libraries available',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '5. Limited Testing Coverage',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '   Current State: Manual testing only',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Impact: No automated unit or widget tests',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Plan: Implement test suite as part of quality assurance phase',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '6. Offline-First Sync Not Implemented',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '   Current State: Architecture planned',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Impact: App requires constant internet connectivity',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Timeline: Critical for Southern Africa deployment (low bandwidth areas)',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Risk Assessment & Mitigation',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '🔴 High Risk: Schedule Slippage',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor(0.8, 0.2, 0.2),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '   Likelihood: Medium | Impact: High',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Mitigation: Weekly sprints, daily standups, clear priority levels',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '🟡 Medium Risk: Data Security Vulnerabilities',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor(0.8, 0.5, 0),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '   Likelihood: Medium | Impact: Critical',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Mitigation: Implement encryption before production release',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Action: Security audit scheduled for week 4 of M5',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '🟡 Medium Risk: Offline Functionality Failure',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor(0.8, 0.5, 0),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '   Likelihood: High | Impact: High',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Mitigation: Make offline-first a Priority 1 requirement',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Testing: Conduct offline/online switch testing extensively',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '🟢 Low Risk: Cross-Platform Compatibility',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor(0.2, 0.6, 0.2),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '   Likelihood: Low | Impact: Medium',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Mitigation: Comprehensive platform testing before M5 release',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '   Status: Flutter framework handles most platform differences',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );

    // ============ PAGE 7: REFERENCES & TECH STACK ============
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Text(
            '8. References & Tech Stack',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor(0.1, 0.5, 0.8),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Libraries & Packages',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Core Framework',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '• Flutter 3.9.2 — Cross-platform mobile framework',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Dart 3.9.2 — Programming language',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'UI & Navigation',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '• go_router (v14.0.0) — Named routing with nested navigation',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• flutter_localizations — Localization support',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• cupertino_icons (v1.0.8) — iOS-style icons',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Localization & Internationalization',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '• intl (v0.20.2) — Internationalization (EN, ZU, XH)',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Data & Storage',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '• path_provider (v2.1.3) — File system access',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• pdf (v3.10.8) — PDF generation (planned for reports)',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• share_plus (v9.0.0) — Share files (PDF export)',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Planned Dependencies (M5)',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '• drift — ORM for SQLite database',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• http — HTTP client for API calls',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• flutter_local_notifications — Push notifications',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• timezone — Timezone support for reminders',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• encrypt — Data encryption/decryption',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• connectivity_plus — Offline detection',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Development Tools',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '• Android Studio / Xcode — Platform SDKs',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• VS Code — Development IDE',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Git — Version control',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Firebase (planned) — Backend services',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Resources & Documentation',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '• Flutter Documentation: https://flutter.dev/docs',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Dart Language: https://dart.dev',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• GoRouter Guide: https://pub.dev/packages/go_router',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Health Data Standards: WHO medication adherence guidelines',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Project Information',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Project Name: MedAdhere (Mzansi Meds Reminder)',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Version: 1.0.0 (Alpha)',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Status: In Active Development (M5)',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Target Markets: Southern Africa',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Primary Languages: English, Zulu, Xhosa',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Platforms: Android, iOS, Windows, Web, Linux, macOS',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Document Generation',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated: May 12, 2026',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Generated by MedAdhere v1.0.0',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );

    final file = File(reportPath);
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
