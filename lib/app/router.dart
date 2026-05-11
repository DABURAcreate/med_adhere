import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/pin_setup_screen.dart';
import '../features/auth/presentation/language_screen.dart';

// Patient
import '../features/patient/presentation/home_screen.dart';
import '../features/patient/presentation/adherence_calendar_screen.dart';
import '../features/patient/presentation/medication_detail_screen.dart';
import '../features/patient/presentation/risk_level_screen.dart';

// Reminders
import '../features/reminders/presentation/reminder_settings_screen.dart';

// Worker — Dashboard
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/dashboard/presentation/patient_list_screen.dart';

// Worker — Patient Management
import '../features/patient_management/presentation/register_patient_screen.dart';
import '../features/patient_management/presentation/medication_schedule_screen.dart';
import '../features/patient_management/presentation/follow_up_screen.dart';
import '../features/patient_management/presentation/patient_detail_screen.dart';

// Worker — Reports
import '../features/reports/presentation/report_screen.dart';

// Caregiver
import '../features/caregiver/presentation/caregiver_link_screen.dart';

class AppRoutes {
  // Shared / Auth
  static const language = '/';
  static const login = '/login';
  static const pinSetup = '/pin-setup';

  // Patient
  static const patientHome = '/patient/home';
  static const adherenceCalendar = '/patient/calendar';
  static const medicationDetail = '/patient/medication/:id';
  static const riskLevel = '/patient/risk';
  static const reminderSettings = '/patient/reminders';

  // Worker
  static const dashboard = '/worker/dashboard';
  static const patientList = '/worker/patients';
  static const patientDetail = '/worker/patients/:id';
  static const registerPatient = '/worker/patients/register';
  static const medicationSchedule = '/worker/patients/:id/schedule';
  static const followUp = '/worker/patients/:id/follow-up';
  static const reports = '/worker/reports';

  // Shared
  static const caregiverLink = '/caregiver/link';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.language,
    debugLogDiagnostics: true,
    routes: [
      // ---------- Auth / Shared ----------
      GoRoute(
        path: AppRoutes.language,
        name: 'language',
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.pinSetup,
        name: 'pinSetup',
        builder: (context, state) => const PinSetupScreen(),
      ),

      // ---------- Patient ----------
      GoRoute(
        path: AppRoutes.patientHome,
        name: 'patientHome',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'calendar',
            name: 'adherenceCalendar',
            builder: (context, state) => const AdherenceCalendarScreen(),
          ),
          GoRoute(
            path: 'risk',
            name: 'riskLevel',
            builder: (context, state) => const RiskLevelScreen(),
          ),
          GoRoute(
            path: 'reminders',
            name: 'reminderSettings',
            builder: (context, state) => const ReminderSettingsScreen(),
          ),
          GoRoute(
            path: 'medication/:id',
            name: 'medicationDetail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return MedicationDetailScreen(medicationId: id);
            },
          ),
        ],
      ),

      // ---------- Worker ----------
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: 'reports',
            name: 'reports',
            builder: (context, state) => const ReportScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.patientList,
        name: 'patientList',
        builder: (context, state) => const PatientListScreen(),
        routes: [
          GoRoute(
            path: 'register',
            name: 'registerPatient',
            builder: (context, state) => const RegisterPatientScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'patientDetail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return PatientDetailScreen(patientId: id);
            },
            routes: [
              GoRoute(
                path: 'schedule',
                name: 'medicationSchedule',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return MedicationScheduleScreen(patientId: id);
                },
              ),
              GoRoute(
                path: 'follow-up',
                name: 'followUp',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return FollowUpScreen(patientId: id);
                },
              ),
            ],
          ),
        ],
      ),

      // ---------- Caregiver (shared) ----------
      GoRoute(
        path: AppRoutes.caregiverLink,
        name: 'caregiverLink',
        builder: (context, state) => const CaregiverLinkScreen(),
      ),
    ],

    // 404 fallback
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}