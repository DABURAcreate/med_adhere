import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Auth
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/pin_setup_screen.dart';
import '../features/auth/presentation/language_screen.dart';
import '../features/auth/presentation/registration_code_screen.dart';
import '../features/auth/presentation/register_worker_screen.dart';

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

// Providers
import '../providers/session_provider.dart';

class AppRoutes {
  // Shared / Auth
  static const language = '/';
  static const login = '/login';
  static const pinSetup = '/pin-setup';
  static const registrationCode = '/registration-code';
  static const workerRegistration = '/register-worker';

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

  static const _authRoutes = {
    '/',
    '/login',
    '/registration-code',
    '/pin-setup',
    '/register-worker',
  };

  static bool isAuthRoute(String path) => _authRoutes.contains(path);
}

class AppRouter {
  static final List<RouteBase> routes = [
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
      builder: (context, state) {
        final patientId = state.extra as int? ?? 0;
        return PinSetupScreen(patientId: patientId);
      },
    ),
    GoRoute(
      path: AppRoutes.registrationCode,
      name: 'registrationCode',
      builder: (context, state) => const RegistrationCodeScreen(),
    ),
    GoRoute(
      path: AppRoutes.workerRegistration,
      name: 'workerRegistration',
      builder: (context, state) => const RegisterWorkerScreen(),
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
    ),
    GoRoute(
      path: AppRoutes.reports,
      name: 'reports',
      builder: (context, state) => const ReportScreen(),
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

    // ---------- Caregiver ----------
    GoRoute(
      path: AppRoutes.caregiverLink,
      name: 'caregiverLink',
      builder: (context, state) => const CaregiverLinkScreen(),
    ),
  ];

  /// Redirects users based on authentication state and role.
  ///
  /// Rules:
  ///   - Auth routes (login, language, etc.): authenticated users are sent to
  ///     their role-specific home.
  ///   - Protected routes: unauthenticated users are sent to login.
  ///   - /patient/* routes: workers are redirected to the dashboard.
  ///   - /worker/* routes: patients are redirected to patient home.
  static String? redirect(BuildContext context, GoRouterState state) {
    final session = context.read<SessionProvider>();
    final isAuth = session.isAuthenticated;
    final path = state.uri.path;

    final isAuthRoute = AppRoutes.isAuthRoute(path);

    if (isAuthRoute) {
      // Authenticated users don't need auth screens — send to their home.
      if (!isAuth) return null;
      return session.isWorker ? AppRoutes.dashboard : AppRoutes.patientHome;
    }

    // All non-auth routes require authentication.
    if (!isAuth) return AppRoutes.login;

    // Workers cannot access patient-only routes.
    if (session.isWorker && path.startsWith('/patient/')) {
      return AppRoutes.dashboard;
    }

    // Patients cannot access worker-only routes.
    if (session.isPatient && path.startsWith('/worker/')) {
      return AppRoutes.patientHome;
    }

    return null;
  }
}
